module Sources.Processing.State exposing (..)

import Date
import Json.Encode as Encode
import Http exposing (Error(..))
import Maybe.Ext as Maybe
import Maybe.Extra as Maybe
import Response.Ext exposing (do)
import Slave.Events exposing (..)
import Slave.Types as Slave exposing (AlienMsg(..))
import Sources.Processing.Ports as Ports
import Sources.Processing.Steps as Steps
import Sources.Processing.Types exposing (..)
import Sources.Processing.Utils exposing (..)
import Sources.Services as Services
import Sources.Types exposing (Service)
import Tracks.Encoding


-- 💧


initialModel : Model
initialModel =
    { origin = defaultOrigin
    , status = Nothing
    , timestamp = Date.fromTime 0
    }



-- 🔥


update : Msg -> Model -> ( Model, Cmd Slave.Msg )
update msg model =
    case msg of
        {- If already processing, do nothing.
           If there are no sources, do nothing.
           If there are sources, start processing the first source.
        -}
        Process origin sources tracks ->
            let
                processingData =
                    List.map
                        (\source ->
                            ( source
                            , List.filter (\t -> t.sourceId == source.id) tracks
                            )
                        )
                        sources

                status =
                    sources
                        |> List.head
                        |> Maybe.map (always processingData)
                        |> Maybe.preferFirst model.status

                command =
                    sources
                        |> List.head
                        |> Maybe.map (Steps.takeFirstStep origin model.timestamp)
                        |> Maybe.preferSecond (Maybe.map (always Cmd.none) model.status)
                        |> Maybe.withDefault Cmd.none
            in
                ($)
                    { model | origin = origin, status = status }
                    [ command ]
                    []

        {- If not processing, do nothing.
           If there are no sources left, do nothing.
           If there are sources left, start processing the next source in line.
        -}
        NextInLine ->
            let
                takeStep =
                    Steps.takeFirstStep model.origin model.timestamp

                maybe =
                    model.status
                        |> Maybe.andThen (List.tail)
                        |> Maybe.andThen (\a -> Maybe.map ((,) a) (List.head a))
                        |> Maybe.map (Tuple.mapSecond Tuple.first)
                        |> Maybe.map (Tuple.mapSecond takeStep)
            in
                ($)
                    { model | status = Maybe.map Tuple.first maybe }
                    [ maybe
                        |> Maybe.map Tuple.second
                        |> Maybe.withDefault Cmd.none
                    ]
                    (case maybe of
                        Just _ ->
                            []

                        Nothing ->
                            [ issue ProcessSourcesCompleted ]
                    )

        {- Phase 1, `prepare`.
           ie. prepare for processing.
        -}
        PrepareStep context (Ok response) ->
            let
                ( processingCmd, topLevelCmd ) =
                    Steps.takePrepareStep context response model.timestamp
            in
                ($)
                    model
                    [ processingCmd ]
                    [ topLevelCmd ]

        PrepareStep context (Err err) ->
            let
                data =
                    Encode.object
                        [ ( "sourceId", Encode.string context.source.id )
                        , ( "message", Encode.string (publicError context.source.service err) )
                        ]
            in
                ($)
                    model
                    [ do NextInLine ]
                    [ issueWithData ReportProcessingError data ]

        {- Phase 2, `makeTree`.
           ie. make a file list/tree.
        -}
        TreeStep context (Ok response) ->
            let
                associatedTracks =
                    model.status
                        |> Maybe.andThen List.head
                        |> Maybe.map Tuple.second
                        |> Maybe.withDefault []

                -- The source data might have changed.
                updatedStatus =
                    case model.status of
                        Just list ->
                            Just
                                (List.map
                                    (\( s, tr ) ->
                                        if s.id == context.source.id then
                                            ( context.source, tr )
                                        else
                                            ( s, tr )
                                    )
                                    list
                                )

                        Nothing ->
                            Nothing
            in
                ($)
                    { model | status = updatedStatus }
                    [ Steps.takeTreeStep context response associatedTracks model.timestamp ]
                    []

        --
        -- Error
        --
        TreeStep context (Err err) ->
            let
                data =
                    Encode.object
                        [ ( "sourceId", Encode.string context.source.id )
                        , ( "message", Encode.string (publicError context.source.service err) )
                        ]
            in
                ($)
                    model
                    [ do NextInLine ]
                    [ issueWithData ReportProcessingError data ]

        --
        -- Remove tracks
        --
        TreeStepRemoveTracks sourceId filePaths ->
            let
                encodedFilePaths =
                    filePaths
                        |> List.map Encode.string
                        |> Encode.list

                encodedSourceId =
                    Encode.string sourceId

                encodedData =
                    Encode.object
                        [ ( "filePaths", encodedFilePaths )
                        , ( "sourceId", encodedSourceId )
                        ]
            in
                (!) model [ issueWithData RemoveTracksByPath encodedData ]

        {- Phase 3, `makeTags`.
           ie. get the tags for each file in the file list.
        -}
        TagsStep tagsContext ->
            let
                validReceivedTags =
                    List.filter Maybe.isJust tagsContext.receivedTags

                insert =
                    case List.length validReceivedTags of
                        0 ->
                            Cmd.none

                        _ ->
                            issueWithData
                                AddTracks
                                (tagsContext
                                    |> Steps.tracksFromTagsContext
                                    |> List.map Tracks.Encoding.encodeTrack
                                    |> Encode.list
                                )

                cmd =
                    model.status
                        |> Maybe.map (List.map Tuple.first)
                        |> Maybe.andThen (Steps.findTagsContextSource tagsContext)
                        |> Maybe.andThen (Steps.takeTagsStep model.timestamp tagsContext)
                        |> Maybe.withDefault (do NextInLine)
            in
                ($) model [ cmd ] [ insert ]

        --
        --
        --
        NoOp ->
            ( model, Cmd.none )



-- 🔥  ~  Constants


defaultOrigin : String
defaultOrigin =
    "origin_not_defined"



-- 🔥  ~  Error Handling


publicError : Service -> Http.Error -> String
publicError service err =
    case err of
        NetworkError ->
            "Cannot connect to this source"

        Timeout ->
            "Source did not respond (timeout)"

        BadStatus response ->
            Services.parseErrorResponse service response.body

        _ ->
            toString err



-- 🌱


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        receiveTorrentTree : ContextForTree -> Msg
        receiveTorrentTree treeContext =
            model.status
                |> Maybe.map (List.map Tuple.first)
                |> Maybe.andThen (Steps.treeContextToContext treeContext)
                |> Maybe.map (\ctx -> TreeStep ctx (Ok ""))
                |> Maybe.withDefault NoOp
    in
        Sub.batch
            [ Ports.receiveTags TagsStep
            , Ports.receiveTorrentTree receiveTorrentTree
            ]

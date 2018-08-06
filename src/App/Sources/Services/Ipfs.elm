module Sources.Services.Ipfs exposing (..)

{-| IPFS Service.

Resources:

  - <https://ipfs.io/docs/api/>

-}

import Date exposing (Date)
import Dict
import Http
import Sources.Services.Ipfs.Marker as Marker
import Sources.Services.Ipfs.Parser as Parser
import Sources.Services.Utils exposing (noPrep)
import Sources.Processing.Types exposing (..)
import Sources.Types exposing (SourceData)


-- Properties
-- 📟


defaults =
    { gateway = "http://localhost:8080"
    , name = "Music from IPFS"
    }


{-| The list of properties we need from the user.

Tuple: (property, label, placeholder, isPassword)
Will be used for the forms.

-}
properties : List ( String, String, String, Bool )
properties =
    [ ( "directoryHash", "Directory object hash", "QmVLDAhCY3X9P2u", False )
    , ( "gateway", "Read-only gateway", defaults.gateway, False )
    , ( "name", "Label", defaults.name, False )
    ]


{-| Initial data set.
-}
initialData : SourceData
initialData =
    Dict.fromList
        [ ( "directoryHash", "" )
        , ( "name", defaults.name )
        , ( "gateway", defaults.gateway )
        ]



-- Preparation


prepare : String -> SourceData -> Marker -> Maybe (Http.Request String)
prepare _ _ _ =
    Nothing



-- Tree


{-| Create a directory tree.
-}
makeTree : Context -> Date -> (Result Http.Error String -> Msg) -> Cmd Msg
makeTree context _ resultMsg =
    let
        srcData =
            context.source.data

        gateway =
            srcData
                |> Dict.get "gateway"
                |> Maybe.withDefault defaults.gateway
                |> String.foldr
                    (\char acc ->
                        if String.isEmpty acc && char == '/' then
                            acc
                        else
                            String.cons char acc
                    )
                    ""

        marker =
            context.treeMarker

        hash =
            case marker of
                InProgress _ ->
                    marker
                        |> Marker.takeOne
                        |> Maybe.withDefault "MISSING_HASH"

                _ ->
                    srcData
                        |> Dict.get "directoryHash"
                        |> Maybe.withDefault "MISSING_HASH"

        url =
            gateway ++ "/api/v0/ls?arg=" ++ hash ++ "&encoding=json"
    in
        url
            |> Http.getString
            |> Http.send resultMsg


{-| Re-export parser functions.
-}
parsePreparationResponse : String -> SourceData -> Marker -> PrepationAnswer Marker
parsePreparationResponse =
    noPrep


parseTreeResponse : String -> Marker -> TreeAnswer Marker
parseTreeResponse =
    Parser.parseTreeResponse


parseErrorResponse : String -> String
parseErrorResponse =
    identity



-- Post


{-| Post process the tree results.

!!! Make sure we only use music files that we can use.

-}
postProcessTree : List String -> List String
postProcessTree =
    identity



-- Track URL


{-| Create a public url for a file.

We need this to play the track.

-}
makeTrackUrl : Date -> SourceData -> HttpMethod -> String -> String
makeTrackUrl _ srcData _ hash =
    let
        gateway =
            srcData
                |> Dict.get "gateway"
                |> Maybe.withDefault defaults.gateway
                |> String.foldr
                    (\char acc ->
                        if String.isEmpty acc && char == '/' then
                            acc
                        else
                            String.cons char acc
                    )
                    ""
    in
        gateway ++ "/ipfs/" ++ hash

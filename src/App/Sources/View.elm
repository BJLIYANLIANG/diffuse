module Sources.View exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Material.Icons.Action as Icons
import Navigation.View as Navigation
import Sources.Types as Sources exposing (Page(..), Service(..), Source)
import Types as TopLevel exposing (Model, Msg(..))
import Utils exposing (cssClass)
import Variables exposing (colorDerivatives)


-- Styles

import Form.Styles as FormStyles
import Styles exposing (Classes(Button, ContentBox))


-- Services

import Sources.Services.AmazonS3 as AmazonS3


-- 🍯


entry : Sources.Page -> Model -> Html Msg
entry page model =
    case page of
        Index ->
            pageIndex model

        New ->
            pageNew model



-- {Page} index


pageIndex : Model -> Html Msg
pageIndex model =
    div
        []
        [ ------------------------------------
          -- Navigation
          ------------------------------------
          Navigation.inside
            [ ( text "Add a new source", "/sources/new" )
            ]

        ------------------------------------
        -- List (TODO)
        ------------------------------------
        , div
            [ cssClass ContentBox ]
            [ h1
                []
                [ text "Sources" ]
            , ul
                []
                (List.map
                    (\s ->
                        li
                            []
                            [ text s.id
                            , a
                                [ s.id
                                    |> Sources.Destroy
                                    |> TopLevel.SourcesMsg
                                    |> onClick
                                ]
                                [ text "Destroy" ]
                            , a
                                [ onClick TopLevel.ProcessSources ]
                                [ text "Process" ]
                            ]
                    )
                    model.sources.collection
                )
            ]
        ]



-- {Page} New


pageNew : Model -> Html Msg
pageNew model =
    div
        []
        [ ------------------------------------
          -- Navigation
          ------------------------------------
          Navigation.inside
            [ ( Icons.list colorDerivatives.text 16, "/sources" )
            ]

        ------------------------------------
        -- Form
        ------------------------------------
        , Html.map SourcesMsg (pageNewForm model)
        ]


pageNewForm : Model -> Html Sources.Msg
pageNewForm model =
    Html.form
        [ cssClass ContentBox
        , onSubmit Sources.SubmitNewSourceForm
        ]
        [ h1
            []
            [ text "Add a new source" ]
        , p
            [ cssClass FormStyles.Intro ]
            [ text """
                A source is a place where your music is stored.
                By connecting a source, the application will scan it
                and keep a list of all the music in it. It will not
                copy anything.
              """
            ]
        , label
            []
            [ text "Source type/service" ]
        , div
            [ cssClass FormStyles.SelectBox ]
            [ select
                []
                [ option
                    [ value "amazon-s3" ]
                    [ text "Amazon S3" ]
                ]
            ]
        , div
            []
            (renderSourceProperties model.sources.newSource)
        , div
            []
            [ button
                [ type_ "submit" ]
                [ text "Create source" ]
            ]
        ]



-- Properties


propertyRenderer : Source -> ( String, String, String, Bool ) -> Html Sources.Msg
propertyRenderer source ( propKey, propLabel, propPlaceholder, isPassword ) =
    div
        []
        [ label
            []
            [ text propLabel ]
        , div
            [ cssClass FormStyles.InputBox ]
            [ input
                [ name propKey
                , onInput (Sources.SetNewSourceProperty source propKey)
                , placeholder propPlaceholder
                , required True
                , type_
                    (if isPassword then
                        "password"
                     else
                        "text"
                    )
                , value
                    (source.data
                        |> Dict.get propKey
                        |> Maybe.withDefault ""
                    )
                ]
                []
            ]
        ]


renderSourceProperties : Source -> List (Html Sources.Msg)
renderSourceProperties source =
    case source.service of
        AmazonS3 ->
            List.map (propertyRenderer source) AmazonS3.properties

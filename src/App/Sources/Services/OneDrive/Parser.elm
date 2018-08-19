module Sources.Services.OneDrive.Parser exposing (parsePreparationResponse, parseTreeResponse, parseErrorResponse)

import Dict
import Json.Decode exposing (..)
import Maybe.Extra
import Sources.Pick
import Sources.Types exposing (SourceData)
import Sources.Processing.Types exposing (Marker(..), PrepationAnswer, TreeAnswer)


-- Preparation


parsePreparationResponse : String -> SourceData -> Marker -> PrepationAnswer Marker
parsePreparationResponse response srcData _ =
    let
        newAccessToken =
            response
                |> decodeString (field "access_token" string)
                |> Result.withDefault ""

        maybeRefreshToken =
            response
                |> decodeString (maybe <| field "refresh_token" string)
                |> Result.toMaybe
                |> Maybe.Extra.join

        refreshTokenUpdater dict =
            case maybeRefreshToken of
                Just refreshToken ->
                    Dict.insert "refreshToken" refreshToken dict

                Nothing ->
                    dict
    in
        srcData
            |> Dict.insert "accessToken" newAccessToken
            |> refreshTokenUpdater
            |> Dict.remove "authCode"
            |> (\s -> { sourceData = s, marker = TheEnd })



-- Tree


parseTreeResponse : String -> Marker -> TreeAnswer Marker
parseTreeResponse response _ =
    let
        x =
            Debug.log "resp" response
    in
        { filePaths =
            []
        , marker =
            TheEnd
        }



-- Error


parseErrorResponse : String -> String
parseErrorResponse response =
    response

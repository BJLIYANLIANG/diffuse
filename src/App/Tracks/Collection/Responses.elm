module Tracks.Collection.Responses exposing (..)

import Dom.Scroll
import Queue.Types
import Response.Ext exposing (do)
import Task
import Tracks.Encoding
import Tracks.Ports as Ports
import Tracks.Types exposing (..)
import Types as TopLevel


{-| Consequences when changing `collection.untouched`.
-}
globalConsequences : Collection -> Collection -> Model -> Cmd TopLevel.Msg
globalConsequences oldCollection newCollection model =
    case oldCollection.untouched /= newCollection.untouched of
        True ->
            let
                encodedTracks =
                    List.map Tracks.Encoding.encodeTrack newCollection.untouched

                search =
                    TopLevel.TracksMsg (Search model.searchTerm)
            in
            Cmd.batch
                [ Ports.updateSearchIndex encodedTracks
                , do TopLevel.AutoGeneratePlaylists
                , do search

                -- Store data
                , if model.initialImportPerformed then
                    do TopLevel.DebounceStoreUserData
                  else
                    Cmd.none
                ]

        False ->
            Cmd.none


{-| Consequences when changing `collection.harvested`.
-}
harvestingConsequences : Collection -> Collection -> Model -> Cmd TopLevel.Msg
harvestingConsequences oldCollection newCollection _ =
    let
        mod =
            Tuple.second >> .id

        old =
            List.map mod oldCollection.harvested

        new =
            List.map mod newCollection.harvested
    in
    case old /= new of
        True ->
            Cmd.batch
                [ do (TopLevel.QueueMsg Queue.Types.Reset)
                , do (TopLevel.TracksMsg Tracks.Types.Recalibrate)
                , 1
                    |> Dom.Scroll.toY "tracks"
                    |> Task.attempt (always TopLevel.NoOp)
                ]

        False ->
            Cmd.none

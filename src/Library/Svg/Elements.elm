module Svg.Elements exposing (blockstackLogo, remoteStorageLogo, spinner)

import Html.Attributes
import Svg exposing (..)
import Svg.Attributes exposing (..)



-- Logos


blockstackLogo : Svg Never
blockstackLogo =
    svg
        [ height "22"
        , viewBox "0 0 512 512"
        , width "22"
        ]
        [ g
            [ fill "none"
            , fillRule "evenodd"
            ]
            [ Svg.path
                [ d "M186.673352,210.979293 C163.559368,210.979293 144.821782,192.302202 144.821782,169.262843 C144.821782,146.223483 163.559368,127.546392 186.673352,127.546392 C209.787336,127.546392 228.524922,146.223483 228.524922,169.262843 C228.524922,192.302202 209.787336,210.979293 186.673352,210.979293 Z M354.079631,210.979293 C330.965647,210.979293 312.228061,192.302202 312.228061,169.262843 C312.228061,146.223483 330.965647,127.546392 354.079631,127.546392 C377.193615,127.546392 395.931201,146.223483 395.931201,169.262843 C395.931201,192.302202 377.193615,210.979293 354.079631,210.979293 Z M354.079631,377.845096 C330.965647,377.845096 312.228061,359.168005 312.228061,336.128646 C312.228061,313.089286 330.965647,294.412195 354.079631,294.412195 C377.193615,294.412195 395.931201,313.089286 395.931201,336.128646 C395.931201,359.168005 377.193615,377.845096 354.079631,377.845096 Z M186.673352,377.845096 C163.559368,377.845096 144.821782,359.168005 144.821782,336.128646 C144.821782,313.089286 163.559368,294.412195 186.673352,294.412195 C209.787336,294.412195 228.524922,313.089286 228.524922,336.128646 C228.524922,359.168005 209.787336,377.845096 186.673352,377.845096 Z"
                , fill "#2C96FF"
                ]
                []
            , Svg.path
                [ d "M158.85157,222.072077 C135.737586,222.072077 117,203.394986 117,180.355626 C117,157.316266 135.737586,138.639175 158.85157,138.639175 C181.965554,138.639175 200.70314,157.316266 200.70314,180.355626 C200.70314,203.394986 181.965554,222.072077 158.85157,222.072077 Z M326.257849,222.072077 C303.143865,222.072077 284.406279,203.394986 284.406279,180.355626 C284.406279,157.316266 303.143865,138.639175 326.257849,138.639175 C349.371833,138.639175 368.109419,157.316266 368.109419,180.355626 C368.109419,203.394986 349.371833,222.072077 326.257849,222.072077 Z M326.257849,388.93788 C303.143865,388.93788 284.406279,370.260789 284.406279,347.221429 C284.406279,324.18207 303.143865,305.504978 326.257849,305.504978 C349.371833,305.504978 368.109419,324.18207 368.109419,347.221429 C368.109419,370.260789 349.371833,388.93788 326.257849,388.93788 Z M158.85157,388.93788 C135.737586,388.93788 117,370.260789 117,347.221429 C117,324.18207 135.737586,305.504978 158.85157,305.504978 C181.965554,305.504978 200.70314,324.18207 200.70314,347.221429 C200.70314,370.260789 181.965554,388.93788 158.85157,388.93788 Z"
                , fill "#E91E63"
                ]
                []
            , Svg.path
                [ d "M172.762461,205.432902 C149.648477,205.432902 130.910891,186.75581 130.910891,163.716451 C130.910891,140.677091 149.648477,122 172.762461,122 C195.876445,122 214.614031,140.677091 214.614031,163.716451 C214.614031,186.75581 195.876445,205.432902 172.762461,205.432902 Z M340.16874,205.432902 C317.054756,205.432902 298.31717,186.75581 298.31717,163.716451 C298.31717,140.677091 317.054756,122 340.16874,122 C363.282724,122 382.02031,140.677091 382.02031,163.716451 C382.02031,186.75581 363.282724,205.432902 340.16874,205.432902 Z M340.16874,372.298705 C317.054756,372.298705 298.31717,353.621614 298.31717,330.582254 C298.31717,307.542894 317.054756,288.865803 340.16874,288.865803 C363.282724,288.865803 382.02031,307.542894 382.02031,330.582254 C382.02031,353.621614 363.282724,372.298705 340.16874,372.298705 Z M172.762461,372.298705 C149.648477,372.298705 130.910891,353.621614 130.910891,330.582254 C130.910891,307.542894 149.648477,288.865803 172.762461,288.865803 C195.876445,288.865803 214.614031,307.542894 214.614031,330.582254 C214.614031,353.621614 195.876445,372.298705 172.762461,372.298705 Z"
                , fill "#270F34"
                ]
                []
            ]
        ]


remoteStorageLogo : Svg Never
remoteStorageLogo =
    svg
        [ height "17"
        , viewBox "0 0 739 853"
        , width "17"

        --
        , Html.Attributes.style "shape-rendering" "geometricPrecision"
        , Html.Attributes.style "text-rendering" "geometricPrecision"
        , Html.Attributes.style "image-rendering" "optimizeQuality"
        , Html.Attributes.style "clip-rule" "evenodd"
        , Html.Attributes.style "fill-rule" "evenodd"
        ]
        [ polygon
            [ fill "#FF4B03"
            , points "370,754 0,542 0,640 185,747 370,853 554,747 739,640 739,525 739,525 739,476 739,427 739,378 653,427 370,589 86,427 86,427 86,361 185,418 370,524 554,418 653,361 739,311 739,213 739,213 554,107 370,0 185,107 58,180 144,230 228,181 370,100 511,181 652,263 370,425 87,263 87,263 0,213 0,213 0,311 0,378 0,427 0,476 86,525 185,582 370,689 554,582 653,525 653,590 653,592"
            ]
            []
        ]



-- Spinner


spinner : Svg Never
spinner =
    svg
        [ class "spinner"
        , height "29"
        , viewBox "0 0 30 30"
        , width "29"
        ]
        [ circle
            [ class "spinner-circle"
            , cx "15"
            , cy "15"
            , fill "none"
            , r "14"
            , strokeLinecap "round"
            , strokeWidth "2"
            ]
            []
        ]
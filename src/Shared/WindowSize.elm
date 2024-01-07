module Shared.WindowSize exposing (WindowSize, initWindowSize, windowSizeDecoder)

import Json.Decode


type alias WindowSize =
    { width : Int
    , height : Int
    }


windowSizeDecoder : Json.Decode.Decoder WindowSize
windowSizeDecoder =
    Json.Decode.map2 WindowSize
        (Json.Decode.field "width" Json.Decode.int)
        (Json.Decode.field "height" Json.Decode.int)


{-| Stub for init
-}
initWindowSize : WindowSize
initWindowSize =
    { width = 1024, height = 768 }

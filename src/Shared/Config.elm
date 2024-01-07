module Shared.Config exposing (Config, configDecoder)

import Json.Decode


type alias Config =
    { backendUrl : String
    }


configDecoder : Json.Decode.Decoder Config
configDecoder =
    Json.Decode.map Config
        (Json.Decode.field "backendUrl" Json.Decode.string)

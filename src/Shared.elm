module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Shared.Config exposing (Config)
import Shared.Model
import Shared.Msg
import Shared.WindowSize exposing (WindowSize, initWindowSize, windowSizeDecoder)



-- FLAGS


type alias Flags =
    { config : Config, windowSize : WindowSize }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map2 Flags
        (Json.Decode.field "config" Shared.Config.configDecoder)
        (Json.Decode.field "windowSize" <| windowSizeDecoder)



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult _ =
    case flagsResult of
        Ok flags ->
            initOk flags

        Err _ ->
            initError


initOk : Flags -> ( Model, Effect Msg )
initOk flags =
    ( { window = flags.windowSize
      , backendUrl = flags.config.backendUrl
      }
    , Effect.none
    )


{-| Note: The type forces us to return some Model, but we only are going to do the redirect to the error page.
-}
initError : ( Model, Effect Msg )
initError =
    let
        meaninglessDefaultModel : Shared.Model.Model
        meaninglessDefaultModel =
            { window = initWindowSize
            , backendUrl = ""
            }
    in
    ( meaninglessDefaultModel
    , Effect.loadExternalUrl "/error.html"
    )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Shared.Msg.NoOp ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none

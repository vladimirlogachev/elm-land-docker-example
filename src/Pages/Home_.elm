module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (Html, source)
import Html.Attributes
import Html.Events
import Http
import Json.Decode as Decode
import Page exposing (Page)
import RemoteData exposing (WebData)
import Route exposing (Route)
import Shared
import View exposing (View)
import VitePluginHelper


page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init shared
        , update = update shared
        , subscriptions = always Sub.none
        , view = view shared
        }


type alias Model =
    { wikiPageTitle : String
    , wikiPageDetails : WebData WikiPageDetails
    }


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared () =
    let
        model =
            { wikiPageTitle = "Elm"
            , wikiPageDetails = RemoteData.NotAsked
            }
    in
    ( model
    , Effect.sendCmd <| getWikiPageDetails shared model.wikiPageTitle
    )



-- UPDATE


type Msg
    = WikiPageTitleChanged String
    | GotWikiPageDetails String (Result Http.Error WikiPageDetails)


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
        WikiPageTitleChanged newTitle ->
            ( { model | wikiPageTitle = newTitle }, Effect.sendCmd <| getWikiPageDetails shared newTitle )

        GotWikiPageDetails requestedTitle res ->
            if requestedTitle == model.wikiPageTitle then
                ( { model | wikiPageDetails = RemoteData.fromResult res }, Effect.none )

            else
                ( model, Effect.none )


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "Elm Land Docker Example"
    , body =
        [ Html.div
            [ Html.Attributes.style "padding" "20px"
            , Html.Attributes.style "font-family" "sans-serif"
            , Html.Attributes.style "display" "flex"
            , Html.Attributes.style "flex-direction" "row"
            , Html.Attributes.style "flex-wrap" "wrap"
            , Html.Attributes.style "gap" "80px"
            , Html.Attributes.class "bg-red-300" -- Tailwind
            ]
            [ viewAssetExample
            , viewApiRequestExample shared model
            ]
        ]
    }


viewHeader : String -> Html Msg
viewHeader text =
    Html.h2
        [ Html.Attributes.style "font-weight" "700"
        , Html.Attributes.style "font-size" "40px"
        , Html.Attributes.style "margin" "20px 0"
        ]
        [ Html.text text ]


viewAssetExample : Html Msg
viewAssetExample =
    Html.div []
        [ viewHeader "Example Asset"
        , Html.img
            [ Html.Attributes.src (VitePluginHelper.asset "/assets/images/example-asset.svg")
            , Html.Attributes.alt "Example asset"
            , Html.Attributes.style "border-radius" "5px"
            ]
            []
        ]



-- WIKI PAGE DETAILS


getWikiPageDetails : Shared.Model -> String -> Cmd Msg
getWikiPageDetails shared pageTitle =
    Http.get
        { url = shared.backendUrl ++ "/rest_v1/page/summary/" ++ pageTitle
        , expect = Http.expectJson (GotWikiPageDetails pageTitle) wikiPageDetailsDecoder
        }


type alias WikiPageDetails =
    { title : String
    , thumbnail : WikiImage
    , extract : String
    }


wikiPageDetailsDecoder : Decode.Decoder WikiPageDetails
wikiPageDetailsDecoder =
    Decode.map3 WikiPageDetails
        (Decode.field "title" Decode.string)
        (Decode.field "thumbnail" wikiImageDecoder)
        (Decode.field "extract" Decode.string)


type alias WikiImage =
    { source : String
    }


wikiImageDecoder : Decode.Decoder WikiImage
wikiImageDecoder =
    Decode.map WikiImage
        (Decode.field "source" Decode.string)


viewApiRequestExample : Shared.Model -> Model -> Html Msg
viewApiRequestExample shared model =
    Html.div []
        [ viewHeader "Example API Request"
        , Html.pre [] [ Html.text <| "backendUrl: " ++ shared.backendUrl ]
        , Html.input
            [ Html.Attributes.placeholder "Wiki Page Title"
            , Html.Attributes.style "margin" "20px 0"
            , Html.Attributes.value model.wikiPageTitle
            , Html.Events.onInput WikiPageTitleChanged
            ]
            []
        , viewWikiPageDetails model.wikiPageDetails
        ]


viewWikiPageDetails : WebData WikiPageDetails -> Html Msg
viewWikiPageDetails wikiPageDetails =
    case wikiPageDetails of
        RemoteData.NotAsked ->
            Html.text ""

        RemoteData.Loading ->
            Html.text "Loading..."

        RemoteData.Success details ->
            Html.div []
                [ Html.h3
                    [ Html.Attributes.style "font-weight" "500"
                    , Html.Attributes.style "font-size" "32px"
                    , Html.Attributes.style "margin" "20px 0"
                    ]
                    [ Html.text details.title ]
                , Html.img
                    [ Html.Attributes.src details.thumbnail.source
                    , Html.Attributes.alt "Example asset"
                    , Html.Attributes.style "border-radius" "5px"
                    , Html.Attributes.style "height" "100px"
                    ]
                    []
                , Html.p [ Html.Attributes.style "max-width" "400px" ] [ Html.text details.extract ]
                ]

        RemoteData.Failure _ ->
            Html.text <| "Sorry, Error"

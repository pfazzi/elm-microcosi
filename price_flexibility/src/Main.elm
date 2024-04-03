port module Main exposing (..)

import Browser
import Html exposing (Html, button, div, input, text)
import Html.Events exposing (onClick, onInput)
import Json.Decode exposing (Decoder, decodeValue, errorToString, field, float, map)
import String


port onEvent : (Json.Decode.Value -> msg) -> Sub msg


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    onEvent
        (\jsonValue ->
            case decodeValue eventDecoder jsonValue of
                Ok data ->
                    EventReceived data

                Err errorMsg ->
                    Debug.log (errorToString errorMsg) NoOp
        )


type alias Model =
    { price : Float
    , discount : Float
    , finalPrice : Float
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        initialModel =
            { price = 0
            , discount = 0
            , finalPrice = 0
            }
    in
    ( initialModel, Cmd.none )


type Msg
    = ApplyDiscount
    | SetDiscount Float
    | EventReceived TotalPriceChanged
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EventReceived payload ->
            ( { model | price = payload.totalPrice }, Cmd.none )

        SetDiscount discount ->
            ( { model | discount = discount }, Cmd.none )

        ApplyDiscount ->
            let
                discountValue =
                    model.discount

                priceValue =
                    model.price

                finalPrice =
                    case ( priceValue, discountValue ) of
                        ( p, d ) ->
                            p - d
            in
            ( { model | finalPrice = finalPrice }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ div [] [ text ("Prezzo Base: " ++ String.fromFloat model.price) ]
        , input [ onInput (\discount -> SetDiscount (Maybe.withDefault 0 (String.toFloat discount))) ] []
        , button [ onClick ApplyDiscount ] [ text "Applica Sconto Commerciale" ]
        , div [] [ text ("Prezzo Finale: " ++ String.fromFloat model.finalPrice) ]
        ]


type alias TotalPriceChanged =
    { totalPrice : Float
    }


eventDecoder : Decoder TotalPriceChanged
eventDecoder =
    map TotalPriceChanged
        (field "totalPrice" float)

module Main exposing (..)

import Browser
import Html exposing (Html, div, input, text, button)
import Html.Events exposing (onClick, onInput)
import String

main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }

type alias Model =
    { price : String
    , discount : String
    , finalPrice : String
    }

init : Model
init =
    { price = "100"
    , discount = ""
    , finalPrice = "100"
    }

type Msg = ApplyDiscount | SetDiscount String

update : Msg -> Model -> Model
update msg model =
    case msg of
        SetDiscount discount ->
            { model | discount = discount}

        ApplyDiscount ->
            let
                discountValue = String.toFloat model.discount
                priceValue = String.toFloat model.price
                finalPrice =
                    case (priceValue, discountValue) of
                        (Just p, Just d) -> p - d
                        _ -> 0
            in
                { model | finalPrice = String.fromFloat finalPrice}

view : Model -> Html Msg
view model =
    div []
        [ div [] [ text ("Prezzo Base: " ++ model.price) ]
        , input [ onInput SetDiscount ] [ ]
        , button [ onClick ApplyDiscount ] [ text "Applica Sconto Commerciale" ]
        , div [] [ text ("Prezzo Finale: " ++ model.finalPrice) ]
        ]

port module DecoderApp exposing (..)

import Json.Decode as Decode exposing (Decoder, Value, decodeValue, errorToString, field, float)
import Platform
import Platform.Cmd exposing (Cmd)


-- Porta in ingresso: riceve un messaggio JSON dal test JS
port decode : (Value -> msg) -> Sub msg

-- Porta in uscita: restituisce "OK: valore" oppure "ERROR: messaggio"
port result : String -> Cmd msg


-- MODEL
type alias Model =
    ()


-- DECODER REALE (quello che vuoi testare)
type alias TotalPriceChanged =
    { totalPrice : Float }

eventDecoder : Decoder TotalPriceChanged
eventDecoder =
    field "totalPrice" float
        |> Decode.map TotalPriceChanged


-- INIT
init : () -> ( Model, Cmd msg )
init _ =
    ( (), Cmd.none )


-- SUBSCRIPTION: ascolta porta "decode"
subscriptions : Model -> Sub Msg
subscriptions _ =
    decode GotJson


-- MESSAGGI
type Msg
    = GotJson Value


-- UPDATE
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotJson value ->
            case decodeValue eventDecoder value of
                Ok decoded ->
                    ( model, result ("OK: " ++ String.fromFloat decoded.totalPrice) )

                Err err ->
                    ( model, result ("ERROR: " ++ errorToString err) )


-- PROGRAM
main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }

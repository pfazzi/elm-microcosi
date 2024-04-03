port module Main exposing (..)

import Browser
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Encode
import String


port publishEvent : ( String, Json.Encode.Value ) -> Cmd msg


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        initialModel =
            { covers =
                [ { id = 1, selected = False, selectedTier = 3, name = "Cover A", tiers = [ { id = 1, label = "Base", price = 100.0 }, { id = 3, label = "Premium", price = 200.0 } ] }
                , { id = 2, selected = False, selectedTier = 6, name = "Cover B", tiers = [ { id = 2, label = "Base", price = 150.0 }, { id = 6, label = "Premium", price = 250.0 } ] }
                , { id = 3, selected = False, selectedTier = 7, name = "Cover C", tiers = [ { id = 3, label = "Base", price = 150.0 }, { id = 7, label = "Premium", price = 250.0 } ] }
                , { id = 4, selected = False, selectedTier = 4, name = "Cover D", tiers = [ { id = 4, label = "Base", price = 150.0 }, { id = 8, label = "Premium", price = 250.0 } ] }
                , { id = 5, selected = False, selectedTier = 5, name = "Cover E", tiers = [ { id = 5, label = "Base", price = 150.0 }, { id = 9, label = "Premium", price = 250.0 } ] }
                ]
            , totalPrice = 0.0
            }
    in
    ( initialModel, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MODEL


type alias Tier =
    { id : Int
    , label : String
    , price : Float
    }


type alias Cover =
    { id : Int
    , name : String
    , tiers : List Tier
    , selectedTier : Int
    , selected : Bool
    }


type alias Model =
    { covers : List Cover
    , totalPrice : Float
    }



-- VIEW


type Msg
    = SelectTier Int String
    | ToggleCover Int Bool


view : Model -> Html Msg
view model =
    Html.div [] (List.map viewCover model.covers)


viewCover : Cover -> Html.Html Msg
viewCover cover =
    Html.div []
        [ Html.input [ Html.Attributes.type_ "checkbox", Html.Attributes.checked cover.selected, Html.Events.onCheck (ToggleCover cover.id) ] []
        , Html.text cover.name
        , Html.select [ Html.Events.onInput (SelectTier cover.id) ]
            (List.map (optionTier cover.selectedTier) cover.tiers)
        ]


optionTier : Int -> Tier -> Html Msg
optionTier selectedTierId tier =
    Html.option
        [ Html.Attributes.value (String.fromInt tier.id)
        , Html.Attributes.selected (tier.id == selectedTierId)
        ]
        [ Html.text (tierLabel tier) ]


tierLabel : Tier -> String
tierLabel tier =
    tier.label ++ " ($ " ++ String.fromFloat tier.price ++ ")"



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleCover coverId selected ->
            let
                updatedCovers =
                    updateSelection coverId selected model.covers

                totalPrice =
                    calculateTotalPrice updatedCovers

                updatedModel =
                    { model | covers = updatedCovers, totalPrice = totalPrice }
            in
            ( updatedModel, publishTotalPriceChanged totalPrice )

        SelectTier coverId tierId ->
            let
                updatedCovers =
                    updateTier coverId (Maybe.withDefault 0 (String.toInt tierId)) model.covers

                totalPrice =
                    calculateTotalPrice updatedCovers

                updatedModel =
                    { model | covers = updatedCovers, totalPrice = totalPrice }
            in
            ( updatedModel, publishTotalPriceChanged totalPrice )


calculateTotalPrice : List Cover -> Float
calculateTotalPrice covers =
    covers
        |> List.filter (\cover -> cover.selected)
        |> List.map (\cover -> findTierPrice cover.selectedTier cover.tiers)
        |> List.sum


findTierPrice : Int -> List Tier -> Float
findTierPrice selectedTierId tiers =
    case List.filter (\tier -> tier.id == selectedTierId) tiers of
        tier :: _ ->
            tier.price

        [] ->
            0.0


updateSelection : Int -> Bool -> List Cover -> List Cover
updateSelection coverId selected covers =
    List.map
        (\cover ->
            if cover.id == coverId then
                { cover | selected = selected }

            else
                cover
        )
        covers


updateTier : Int -> Int -> List Cover -> List Cover
updateTier coverId tierId covers =
    List.map
        (\cover ->
            if cover.id == coverId then
                { cover | selectedTier = tierId }

            else
                cover
        )
        covers



-- PUBLIC EVENTS


type alias TotalPriceChangedToJson =
    { totalPrice : Float
    }


publishTotalPriceChanged : Float -> Cmd msg
publishTotalPriceChanged totalPrice =
    publishEvent ( "covers_list.total_price_changed", totalPriceChangedToJson { totalPrice = totalPrice } )



-- ENCODERS


totalPriceChangedToJson : TotalPriceChangedToJson -> Json.Encode.Value
totalPriceChangedToJson event =
    Json.Encode.object
        [ ( "totalPrice", Json.Encode.float event.totalPrice )
        ]

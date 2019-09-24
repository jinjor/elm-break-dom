port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, li, text, ul)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)


port insertBeforeChild : String -> Cmd msg


port removeChild : String -> Cmd msg


port done : (() -> msg) -> Sub msg


type Msg
    = InsertBeforeChild String
    | RemoveChild String
    | Done


main : Program () String Msg
main =
    Browser.element
        { init = \_ -> ( "before", Cmd.none )
        , update = update
        , subscriptions = \_ -> done (always Done)
        , view =
            \model ->
                ul []
                    [ insert1 model
                    , insert2 model
                    , insert3 model
                    , insert4 model
                    , insert5 model
                    , remove1 model
                    , remove2 model
                    , remove3 model
                    , remove4 model
                    , remove5 model
                    ]
        }


update : Msg -> String -> ( String, Cmd Msg )
update msg model =
    case msg of
        InsertBeforeChild id ->
            ( model, insertBeforeChild id )

        RemoveChild id ->
            ( model, removeChild id )

        Done ->
            ( "after", Cmd.none )


wrap : (String -> Msg) -> String -> Html Msg -> Html Msg
wrap toMsg id_ content =
    li [ id id_, style "padding" "20px" ]
        [ content
        , button [ onClick (toMsg id_) ] [ text id_ ]
        ]



-- INSERT <div>PLUGIN NODE</div> BEFORE "#child"


{-| Cannot read property 'replaceData' of undefined
-}
insert1 : String -> Html Msg
insert1 model =
    wrap InsertBeforeChild "insert1" <|
        div [ class "parent" ] [ div [ class "child" ] [ div [] [ text model ] ] ]


{-| domNode.replaceData is not a function
-}
insert2 : String -> Html Msg
insert2 model =
    wrap InsertBeforeChild "insert2" <|
        div [ class "parent" ] [ div [ class "child" ] [], text model ]


{-| Expected:

    <div class="parent"><div>PLUGIN NODE</div><div class="child">after</div></div>

Actual:

    <div class="parent"><div>after</div><div class="child">before</div></div>

-}
insert3 : String -> Html Msg
insert3 model =
    wrap InsertBeforeChild "insert3" <|
        div [ class "parent" ] [ div [ class "child" ] [ text model ] ]


{-| Expected:

    <div class="parent"><div>PLUGIN NODE</div><div class="child after"></div></div>

Actual:

    <div class="parent"><div class="after">PLUGIN NODE</div><div class="child before"></div></div>

-}
insert4 : String -> Html Msg
insert4 model =
    wrap InsertBeforeChild "insert4" <|
        div [ class "parent" ] [ div [ class "child", class model ] [] ]


{-| No error
-}
insert5 : String -> Html Msg
insert5 model =
    wrap InsertBeforeChild "insert5" <|
        div [ class "parent" ] [ text model, div [ class "child" ] [] ]


{-| Cannot read property 'childNodes' of undefined
-}
remove1 : String -> Html Msg
remove1 model =
    wrap RemoveChild "remove1" <|
        div [ class "parent" ] [ div [ class "child" ] [ text model ] ]


{-| Cannot read property 'childNodes' of undefined
-}
remove2 : String -> Html Msg
remove2 model =
    wrap RemoveChild "remove2" <|
        div [ class "parent" ] [ div [ class "child" ] [ div [] [ text model ] ] ]


{-| Cannot read property 'replaceData' of undefined
-}
remove3 : String -> Html Msg
remove3 model =
    wrap RemoveChild "remove3" <|
        div [ class "parent" ] [ div [ class "child" ] [], text model ]


{-| Cannot set property 'className' of undefined
-}
remove4 : String -> Html Msg
remove4 model =
    wrap RemoveChild "remove4" <|
        div [ class "parent" ] [ div [ class "child", class model ] [] ]


{-| No error
-}
remove5 : String -> Html Msg
remove5 model =
    wrap RemoveChild "remove5" <|
        div [ class "parent" ] [ text model, div [ class "child" ] [] ]

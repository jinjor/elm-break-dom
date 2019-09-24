port module Insertion exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, id)


port break : () -> Cmd msg


port broke : (String -> msg) -> Sub msg


main : Program () String String
main =
    Browser.element
        { init = \_ -> ( "hello", break () )
        , update = \msg _ -> ( msg, Cmd.none )
        , subscriptions = \_ -> broke identity
        , view = error1
        }



-- INSERT <div>PLUGIN NODE</div> BEFORE "#child"


{-| Cannot read property 'replaceData' of undefined
-}
error1 : String -> Html msg
error1 model =
    div [ id "parent" ] [ div [ id "child" ] [ div [] [ text model ] ] ]


{-| domNode.replaceData is not a function
-}
error2 : String -> Html msg
error2 model =
    div [ id "parent" ] [ div [ id "child" ] [], text model ]


{-| Expected:

    <div id="parent"><div>PLUGIN NODE</div><div id="child">bye</div></div>

Actual:

    <div id="parent"><div>bye</div><div id="child">hello</div></div>

-}
broken1 : String -> Html msg
broken1 model =
    div [ id "parent" ] [ div [ id "child" ] [ text model ] ]


{-| Expected:

    <div id="parent"><div>PLUGIN NODE</div><div id="child" class="bye"></div></div>

Actual:

    <div id="parent"><div class="bye">PLUGIN NODE</div><div id="child" class="hello"></div></div>

-}
broken2 : String -> Html msg
broken2 model =
    div [ id "parent" ] [ div [ id "child", class model ] [] ]


noError : String -> Html msg
noError model =
    div [ id "parent" ] [ text model, div [ id "child" ] [] ]

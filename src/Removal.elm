port module Removal exposing (main)

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



-- REMOVE "#child"


{-| Cannot read property 'childNodes' of undefined
-}
error1 : String -> Html msg
error1 model =
    div [ id "parent" ] [ div [ id "child" ] [ text model ] ]


{-| Cannot read property 'childNodes' of undefined
-}
error2 : String -> Html msg
error2 model =
    div [ id "parent" ] [ div [ id "child" ] [ div [] [ text model ] ] ]


{-| Cannot read property 'replaceData' of undefined
-}
error3 : String -> Html msg
error3 model =
    div [ id "parent" ] [ div [ id "child" ] [], text model ]


{-| Cannot set property 'className' of undefined
-}
error4 : String -> Html msg
error4 model =
    div [ id "parent" ] [ div [ id "child", class model ] [] ]


noError : String -> Html msg
noError model =
    div [ id "parent" ] [ text model, div [ id "child" ] [] ]

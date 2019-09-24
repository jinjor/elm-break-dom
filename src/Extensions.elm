port module Extensions exposing (main)

import Browser
import Html exposing (Html, button, div, li, text, textarea, ul)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)


port focusTextarea : String -> Cmd msg


port done : (() -> msg) -> Sub msg


type Msg
    = FocusTextarea String
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
                    [ textarea1 model
                    ]
        }


update : Msg -> String -> ( String, Cmd Msg )
update msg model =
    case msg of
        FocusTextarea id ->
            ( model, focusTextarea id )

        Done ->
            ( "after", Cmd.none )


wrap : (String -> Msg) -> String -> Html Msg -> Html Msg
wrap toMsg id_ content =
    li [ id id_, style "padding" "20px" ]
        [ content
        , button [ onClick (toMsg id_) ] [ text id_ ]
        ]



-- VARIOUS PATTERNS


{-| for Grammerly
-}
textarea1 : String -> Html Msg
textarea1 model =
    wrap FocusTextarea "textarea1" <|
        div [ class "parent" ] [ textarea [] [ text model ] ]

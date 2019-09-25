port module Extensions exposing (main)

import Browser
import Html exposing (Html, button, form, li, text, textarea, ul)
import Html.Attributes exposing (class, id, rows, style, value)
import Html.Events exposing (onClick)
import Set exposing (Set)


port focusTextarea : String -> Cmd msg


port done : (String -> msg) -> Sub msg


type Msg
    = FocusTextarea String
    | Done String


type alias Model =
    Set String


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( Set.empty, Cmd.none )
        , update = update
        , subscriptions = \_ -> done Done
        , view =
            \model ->
                ul []
                    [ textarea1 model
                    , textarea2 model
                    , textarea3 model
                    ]
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FocusTextarea id ->
            ( model, focusTextarea id )

        Done id ->
            ( Set.insert id model, Cmd.none )


wrap : (String -> Msg) -> String -> Html Msg -> Html Msg
wrap toMsg id_ content =
    li [ id id_, style "padding" "20px" ]
        [ content
        , button [ onClick (toMsg id_) ] [ text id_ ]
        ]


beforeOrAfter : String -> Model -> String
beforeOrAfter id model =
    if Set.member id model then
        "after"

    else
        "before"



-- VARIOUS PATTERNS


{-| for Grammarly

    domNode.replaceData is not a function

-}
textarea1 : Model -> Html Msg
textarea1 model =
    wrap FocusTextarea "textarea1" <|
        form
            [ class "parent"
            , style "position" "relative"
            ]
            [ text (beforeOrAfter "textarea1" model)
            , textarea
                [ style "display" "block"
                , style "width" "100%"
                , rows 3
                , value (beforeOrAfter "textarea1" model)
                ]
                []
            ]


{-| for Grammarly

domNode.replaceData is not a function

-}
textarea2 : Model -> Html Msg
textarea2 model =
    wrap FocusTextarea "textarea2" <|
        form
            [ class "parent"
            , style "position" "relative"
            ]
            [ textarea
                [ style "display" "block"
                , style "width" "100%"
                , rows 3
                , value (beforeOrAfter "textarea2" model)
                ]
                [ text (beforeOrAfter "textarea2" model) ]
            ]


{-| for Grammarly

Expected:

    <div class="parent">
        <grammarly-extension></grammarly-extension>
        <textarea class="after"></textarea>
    </div>

Actual:

    <div class="parent">
        <grammarly-extension class="after"></grammarly-extension>
        <textarea class="before"></textarea>
    </div>

-}
textarea3 : Model -> Html Msg
textarea3 model =
    wrap FocusTextarea "textarea3" <|
        form
            [ class "parent"
            , style "position" "relative"
            ]
            [ textarea
                [ style "display" "block"
                , style "width" "100%"
                , rows 3
                , value (beforeOrAfter "textarea3" model)
                , class (beforeOrAfter "textarea3" model)
                ]
                []
            ]

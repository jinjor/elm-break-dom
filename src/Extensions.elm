port module Extensions exposing (Model, Msg, init, main, noop, onUrlRequest, subscriptions, update, view)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, form, h1, h2, hr, li, text, textarea, ul)
import Html.Attributes exposing (class, href, id, rows, style, target, value)
import Html.Events exposing (onClick)
import Set exposing (Set)
import Url


port focusTextarea : String -> Cmd msg


port done : (String -> msg) -> Sub msg


type Msg
    = NoOp
    | UrlRequest UrlRequest
    | FocusTextarea String
    | Done String


onUrlRequest : UrlRequest -> Msg
onUrlRequest =
    UrlRequest


noop : Msg
noop =
    NoOp


type alias Model =
    Set String


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Set.empty, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UrlRequest urlRequest ->
            ( model
            , case urlRequest of
                Internal url ->
                    Nav.load (Url.toString url)

                External url ->
                    Nav.load url
            )

        FocusTextarea id ->
            ( model, focusTextarea id )

        Done id ->
            ( Set.insert id model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    done Done


view : Model -> Html Msg
view model =
    div []
        [ div [ id "mocha" ]
            [ div [ class "suite" ]
                [ h2
                    [ style "margin-bottom" "1em" ]
                    [ a
                        [ target "_blank"
                        , href "https://github.com/jinjor/elm-break-dom"
                        ]
                        [ text "Source (GitHub)" ]
                    ]
                ]
            , div [ class "suite" ]
                [ h1 [] [ text "Variations" ]
                , ul []
                    [ li [ class "suite" ]
                        [ h1 [] [ text "Original" ]
                        , ul []
                            [ li [ class "test" ] [ h2 [] [ a [ href "?" ] [ text "application" ] ] ]
                            , li [ class "test" ] [ h2 [] [ a [ href "?main=element" ] [ text "element" ] ] ]
                            , li [ class "test" ] [ h2 [] [ a [ href "?test=manual" ] [ text "application (manual)" ] ] ]
                            , li [ class "test" ] [ h2 [] [ a [ href "?main=element&test=manual" ] [ text "element (manual)" ] ] ]
                            ]
                        ]
                    , li [ class "suite" ]
                        [ h1 [] [ text "Patched" ]
                        , ul []
                            [ li [ class "test" ] [ h2 [] [ a [ href "?src=patched" ] [ text "application" ] ] ]
                            , li [ class "test" ] [ h2 [] [ a [ href "?src=patched&main=element" ] [ text "element" ] ] ]
                            , li [ class "test" ] [ h2 [] [ a [ href "?src=patched&test=manual" ] [ text "application (manual)" ] ] ]
                            , li [ class "test" ] [ h2 [] [ a [ href "?src=patched&main=element&test=manual" ] [ text "element (manual)" ] ] ]
                            ]
                        ]
                    ]
                ]
            ]
        , hr [] []
        , ul []
            [ justUpdate model
            , textarea1 model
            , textarea2 model
            , textarea3 model
            ]
        ]


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


{-| Just call update
-}
justUpdate : Model -> Html Msg
justUpdate _ =
    wrap (always NoOp) "update" <|
        text ""


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

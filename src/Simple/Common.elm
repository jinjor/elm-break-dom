port module Simple.Common exposing (Model, Msg, init, main, noop, onUrlRequest, subscriptions, update, view)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html, button, div, li, text, ul)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
import Set exposing (Set)
import Url


port insertBeforeChild : String -> Cmd msg


port removeChild : String -> Cmd msg


port done : (String -> msg) -> Sub msg


type Msg
    = NoOp
    | UrlRequest UrlRequest
    | InsertBeforeChild String
    | RemoveChild String
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

        InsertBeforeChild id ->
            ( model, insertBeforeChild id )

        RemoveChild id ->
            ( model, removeChild id )

        Done id ->
            ( Set.insert id model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    done Done


view : Model -> Html Msg
view model =
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



-- INSERT <div>PLUGIN NODE</div> BEFORE "#child"


{-| Cannot read property 'replaceData' of undefined
-}
insert1 : Model -> Html Msg
insert1 model =
    wrap InsertBeforeChild "insert1" <|
        div [ class "parent" ] [ div [ class "child" ] [ div [] [ text (beforeOrAfter "insert1" model) ] ] ]


{-| domNode.replaceData is not a function
-}
insert2 : Model -> Html Msg
insert2 model =
    wrap InsertBeforeChild "insert2" <|
        div [ class "parent" ] [ div [ class "child" ] [], text (beforeOrAfter "insert2" model) ]


{-| Expected:

    <div class="parent">
        <div>PLUGIN NODE</div>
        <div class="child">after</div>
    </div>

Actual:

    <div class="parent">
        <div>after</div>
        <div class="child">before</div>
    </div>

-}
insert3 : Model -> Html Msg
insert3 model =
    wrap InsertBeforeChild "insert3" <|
        div [ class "parent" ] [ div [ class "child" ] [ text (beforeOrAfter "insert3" model) ] ]


{-| Expected:

    <div class="parent">
        <div>PLUGIN NODE</div>
        <div class="child after"></div>
    </div>

Actual:

    <div class="parent">
        <div class="after">PLUGIN NODE</div>
        <div class="child before"></div>
    </div>

-}
insert4 : Model -> Html Msg
insert4 model =
    wrap InsertBeforeChild "insert4" <|
        div [ class "parent" ] [ div [ class "child", class (beforeOrAfter "insert4" model) ] [] ]


{-| No error
-}
insert5 : Model -> Html Msg
insert5 model =
    wrap InsertBeforeChild "insert5" <|
        div [ class "parent" ] [ text (beforeOrAfter "insert5" model), div [ class "child" ] [] ]



-- REMOVE "#child"


{-| Cannot read property 'childNodes' of undefined
-}
remove1 : Model -> Html Msg
remove1 model =
    wrap RemoveChild "remove1" <|
        div [ class "parent" ] [ div [ class "child" ] [ text (beforeOrAfter "remove1" model) ] ]


{-| Cannot read property 'childNodes' of undefined
-}
remove2 : Model -> Html Msg
remove2 model =
    wrap RemoveChild "remove2" <|
        div [ class "parent" ] [ div [ class "child" ] [ div [] [ text (beforeOrAfter "remove2" model) ] ] ]


{-| Cannot read property 'replaceData' of undefined
-}
remove3 : Model -> Html Msg
remove3 model =
    wrap RemoveChild "remove3" <|
        div [ class "parent" ] [ div [ class "child" ] [], text (beforeOrAfter "remove3" model) ]


{-| Cannot set property 'className' of undefined
-}
remove4 : Model -> Html Msg
remove4 model =
    wrap RemoveChild "remove4" <|
        div [ class "parent" ] [ div [ class "child", class (beforeOrAfter "remove4" model) ] [] ]


{-| No error
-}
remove5 : Model -> Html Msg
remove5 model =
    wrap RemoveChild "remove5" <|
        div [ class "parent" ] [ text (beforeOrAfter "remove5" model), div [ class "child" ] [] ]

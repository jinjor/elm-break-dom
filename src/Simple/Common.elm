port module Simple.Common exposing (Model, Msg, init, main, noop, onUrlRequest, subscriptions, update, view)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html, button, div, li, node, text, ul)
import Html.Attributes exposing (class, id, style, title)
import Html.Events exposing (onClick)
import Set exposing (Set)
import Url


port insertIntoBody : Bool -> Cmd msg


port insertBeforeChild : String -> Cmd msg


port removeChild : String -> Cmd msg


port wrapChild : String -> Cmd msg


port updateAttribute : String -> Cmd msg


port done : (String -> msg) -> Sub msg


type Msg
    = NoOp
    | UrlRequest UrlRequest
    | InsertIntoBody Bool
    | InsertBeforeChild String
    | RemoveChild String
    | WrapChild String
    | UpdateAttribute String
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

        InsertIntoBody top ->
            ( model, insertIntoBody top )

        InsertBeforeChild id ->
            ( model, insertBeforeChild id )

        RemoveChild id ->
            ( model, removeChild id )

        WrapChild id ->
            ( model, wrapChild id )

        UpdateAttribute id ->
            ( model, updateAttribute id )

        Done id ->
            ( Set.insert id model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    done Done


view : Model -> Html Msg
view model =
    ul []
        [ insertIntoBody1 model
        , insertIntoBody2 model
        , insert1 model
        , insert2 model
        , insert3 model
        , insert4 model
        , insert5 model
        , remove1 model
        , remove2 model
        , remove3 model
        , remove4 model
        , remove5 model
        , wrap1 model
        , wrap2 model
        , wrap3 model
        , wrap4 model
        , wrap5 model
        , wrap6 model
        , wrap7 model
        , wrap8 model
        , updateAttribute1 model
        , updateAttribute2 model
        , updateAttribute3 model
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



-- INSERT INTO <body>


{-| -}
insertIntoBody1 : Model -> Html Msg
insertIntoBody1 _ =
    wrap (always (InsertIntoBody True)) "insert-into-body1" <|
        text ""


{-| -}
insertIntoBody2 : Model -> Html Msg
insertIntoBody2 _ =
    wrap (always (InsertIntoBody False)) "insert-into-body2" <|
        text ""



-- INSERT <div>EXTENSION NODE</div> BEFORE ".child"


{-| Cannot read property 'replaceData' of undefined
-}
insert1 : Model -> Html Msg
insert1 model =
    wrap InsertBeforeChild "insert1" <|
        div [ class "parent" ] [ div [ class "child" ] [ div [] [ text (beforeOrAfter "insert1" model) ] ] ]


{-| Expected:

    <div class="parent">
        <div>EXTENSION NODE</div>
        <div class="child">after</div>
    </div>

Actual:

    <div class="parent">
        <div>after</div>
        <div class="child">before</div>
    </div>

-}
insert2 : Model -> Html Msg
insert2 model =
    wrap InsertBeforeChild "insert2" <|
        div [ class "parent" ] [ div [ class "child" ] [ text (beforeOrAfter "insert2" model) ] ]


{-| domNode.replaceData is not a function
-}
insert3 : Model -> Html Msg
insert3 model =
    wrap InsertBeforeChild "insert3" <|
        div [ class "parent" ] [ div [ class "child" ] [], text (beforeOrAfter "insert3" model) ]


{-| Expected:

    <div class="parent">
        <div>EXTENSION NODE</div>
        <div class="child after"></div>
    </div>

Actual:

    <div class="parent">
        <div class="after">EXTENSION NODE</div>
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



-- REMOVE ".child"


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



-- WRAP ".child" into <font>


{-| -}
wrap1 : Model -> Html Msg
wrap1 model =
    wrap WrapChild "wrap1" <|
        div [ class "parent" ] [ div [ class "child" ] [ text (beforeOrAfter "wrap1" model) ] ]


{-| -}
wrap2 : Model -> Html Msg
wrap2 model =
    wrap WrapChild "wrap2" <|
        div [ class "parent" ] [ div [ class "child", class (beforeOrAfter "wrap2" model) ] [] ]


{-| -}
wrap3 : Model -> Html Msg
wrap3 model =
    wrap WrapChild "wrap3" <|
        div [ class "parent" ] [ div [ class "child" ] [], text (beforeOrAfter "wrap3" model) ]


{-| -}
wrap4 : Model -> Html Msg
wrap4 model =
    wrap WrapChild "wrap4" <|
        div [ class "parent" ] [ text (beforeOrAfter "wrap4" model), div [ class "child" ] [] ]


{-| -}
wrap5 : Model -> Html Msg
wrap5 model =
    wrap WrapChild "wrap5" <|
        div [ class "parent" ] [ node "font" [ class "child" ] [ text (beforeOrAfter "wrap5" model) ] ]


{-| Expected:

    <font><font class="child after"></font></font>

or

    <font class="child after"></font>

Actual:

    <font class="child after"><font class="child before"></font></font>

-}
wrap6 : Model -> Html Msg
wrap6 model =
    wrap WrapChild "wrap6" <|
        div [ class "parent" ] [ node "font" [ class "child", class (beforeOrAfter "wrap6" model) ] [] ]


{-| -}
wrap7 : Model -> Html Msg
wrap7 model =
    wrap WrapChild "wrap7" <|
        div [ class "parent" ] [ node "font" [ class "child" ] [], text (beforeOrAfter "wrap7" model) ]


{-| -}
wrap8 : Model -> Html Msg
wrap8 model =
    wrap WrapChild "wrap8" <|
        div [ class "parent" ] [ text (beforeOrAfter "wrap8" model), node "font" [ class "child" ] [] ]



-- REPLACE title of ".parent" WITH "break"


{-| This should be safe.
-}
updateAttribute1 : Model -> Html Msg
updateAttribute1 model =
    wrap UpdateAttribute "update-attribute1" <|
        div
            [ class "parent"
            , class (beforeOrAfter "update-attribute1" model)
            ]
            [ text (beforeOrAfter "update-attribute1" model) ]


{-| This should be safe.
-}
updateAttribute2 : Model -> Html Msg
updateAttribute2 model =
    wrap UpdateAttribute "update-attribute2" <|
        div
            [ class "parent"
            , title "hello"
            , class (beforeOrAfter "update-attribute2" model)
            ]
            [ text (beforeOrAfter "update-attribute2" model) ]


{-| -}
updateAttribute3 : Model -> Html Msg
updateAttribute3 model =
    wrap UpdateAttribute "update-attribute3" <|
        div
            [ class "parent"
            , title (beforeOrAfter "update-attribute3" model)
            , class (beforeOrAfter "update-attribute3" model)
            ]
            [ text (beforeOrAfter "update-attribute2" model) ]

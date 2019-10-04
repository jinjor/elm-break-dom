port module Simple.Common exposing (Model, Msg, init, main, noop, onUrlRequest, subscriptions, update, view)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, li, node, text, ul)
import Html.Attributes exposing (class, id, style, title)
import Html.Events exposing (onClick)
import Set exposing (Set)
import Url


port insertIntoBody : Bool -> Cmd msg


port insertBeforeTarget : String -> Cmd msg


port removeTarget : String -> Cmd msg


port wrapTarget : String -> Cmd msg


port updateAttribute : String -> Cmd msg


port done : (String -> msg) -> Sub msg


type Msg
    = NoOp
    | UrlRequest UrlRequest
    | InsertIntoBody Bool
    | InsertBeforeTarget String
    | RemoveTarget String
    | WrapTarget String
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

        InsertBeforeTarget id ->
            ( model, insertBeforeTarget id )

        RemoveTarget id ->
            ( model, removeTarget id )

        WrapTarget id ->
            ( model, wrapTarget id )

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
        , insert6 model
        , insert7 model
        , insert8 model
        , insert9 model
        , insert10 model
        , insert11 model
        , insert12 model
        , insert13 model
        , insert14 model
        , insert15 model
        , insert16 model
        , insert17 model
        , insert18 model
        , insert19 model
        , insert20 model
        , insert21 model
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



-- INSERT <div>EXTENSION NODE</div> BEFORE ".target"


{-| Cannot read property 'replaceData' of undefined
-}
insert1 : Model -> Html Msg
insert1 model =
    wrap InsertBeforeTarget "insert1" <|
        div [] [ div [ class "target" ] [ div [] [ text (beforeOrAfter "insert1" model) ] ] ]


{-| Expected:

    <div>
        <div>EXTENSION NODE</div>
        <div class="target">after</div>
    </div>

Actual:

    <div>
        <div>after</div>
        <div class="target">before</div>
    </div>

-}
insert2 : Model -> Html Msg
insert2 model =
    wrap InsertBeforeTarget "insert2" <|
        div [] [ div [ class "target" ] [ text (beforeOrAfter "insert2" model) ] ]


{-| domNode.replaceData is not a function
-}
insert3 : Model -> Html Msg
insert3 model =
    wrap InsertBeforeTarget "insert3" <|
        div [] [ div [ class "target" ] [], text (beforeOrAfter "insert3" model) ]


{-| Expected:

    <div>
        <div>EXTENSION NODE</div>
        <div class="target after"></div>
    </div>

Actual:

    <div>
        <div class="after">EXTENSION NODE</div>
        <div class="target before"></div>
    </div>

-}
insert4 : Model -> Html Msg
insert4 model =
    wrap InsertBeforeTarget "insert4" <|
        div [] [ div [ class "target", class (beforeOrAfter "insert4" model) ] [] ]


{-| No error
-}
insert5 : Model -> Html Msg
insert5 model =
    wrap InsertBeforeTarget "insert5" <|
        div [] [ text (beforeOrAfter "insert5" model), div [ class "target" ] [] ]


insert6 : Model -> Html Msg
insert6 model =
    wrap InsertBeforeTarget "insert6" <|
        div []
            [ if beforeOrAfter "insert6" model == "before" then
                text "1"

              else
                div [ class "e1" ] []
            , div [ class "target" ] []
            ]


insert7 : Model -> Html Msg
insert7 model =
    wrap InsertBeforeTarget "insert7" <|
        div []
            [ if beforeOrAfter "insert7" model == "before" then
                div [ class "e1" ] []

              else
                text ""
            , div [ class "target" ] []
            ]


insert8 : Model -> Html Msg
insert8 model =
    wrap InsertBeforeTarget "insert8" <|
        div []
            (if beforeOrAfter "insert8" model == "before" then
                [ div [ class "target" ] [] ]

             else
                []
            )


insert9 : Model -> Html Msg
insert9 model =
    wrap InsertBeforeTarget "insert9" <|
        div []
            (if beforeOrAfter "insert9" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ text "", div [ class "target" ] [] ]
            )


insert10 : Model -> Html Msg
insert10 model =
    wrap InsertBeforeTarget "insert10" <|
        div []
            (if beforeOrAfter "insert10" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ div [ class "e1" ] [], div [ class "target" ] [] ]
            )


insert11 : Model -> Html Msg
insert11 model =
    wrap InsertBeforeTarget "insert11" <|
        div []
            (if beforeOrAfter "insert11" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ a [ class "e1" ] [], div [ class "target" ] [] ]
            )


insert12 : Model -> Html Msg
insert12 model =
    wrap InsertBeforeTarget "insert12" <|
        div []
            (if beforeOrAfter "insert12" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ a [ class "e1" ] [] ]
            )


insert13 : Model -> Html Msg
insert13 model =
    wrap InsertBeforeTarget "insert13" <|
        div []
            (if beforeOrAfter "insert13" model == "before" then
                [ div [ class "e1" ] [], div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [] ]
            )


insert14 : Model -> Html Msg
insert14 model =
    wrap InsertBeforeTarget "insert14" <|
        div []
            (if beforeOrAfter "insert14" model == "before" then
                [ a [ class "e1" ] [], div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [] ]
            )


insert15 : Model -> Html Msg
insert15 model =
    wrap InsertBeforeTarget "insert15" <|
        div []
            (if beforeOrAfter "insert15" model == "before" then
                [ text "", div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [] ]
            )


insert16 : Model -> Html Msg
insert16 model =
    wrap InsertBeforeTarget "insert16" <|
        div []
            (if beforeOrAfter "insert16" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [], text "" ]
            )


insert17 : Model -> Html Msg
insert17 model =
    wrap InsertBeforeTarget "insert17" <|
        div []
            (if beforeOrAfter "insert17" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [], div [ class "e1" ] [] ]
            )


insert18 : Model -> Html Msg
insert18 model =
    wrap InsertBeforeTarget "insert18" <|
        div []
            (if beforeOrAfter "insert18" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [], a [ class "e1" ] [] ]
            )


insert19 : Model -> Html Msg
insert19 model =
    wrap InsertBeforeTarget "insert19" <|
        div []
            (if beforeOrAfter "insert19" model == "before" then
                [ div [ class "target" ] [], div [ class "e1" ] [] ]

             else
                [ div [ class "target" ] [] ]
            )


insert20 : Model -> Html Msg
insert20 model =
    wrap InsertBeforeTarget "insert20" <|
        div []
            (if beforeOrAfter "insert20" model == "before" then
                [ div [ class "target" ] [], a [ class "e1" ] [] ]

             else
                [ div [ class "target" ] [] ]
            )


insert21 : Model -> Html Msg
insert21 model =
    wrap InsertBeforeTarget "insert21" <|
        div []
            (if beforeOrAfter "insert21" model == "before" then
                [ div [ class "target" ] [], text "" ]

             else
                [ div [ class "target" ] [] ]
            )



-- REMOVE ".target"


{-| Cannot read property 'childNodes' of undefined
-}
remove1 : Model -> Html Msg
remove1 model =
    wrap RemoveTarget "remove1" <|
        div [] [ div [ class "target" ] [ text (beforeOrAfter "remove1" model) ] ]


{-| Cannot read property 'childNodes' of undefined
-}
remove2 : Model -> Html Msg
remove2 model =
    wrap RemoveTarget "remove2" <|
        div [] [ div [ class "target" ] [ div [] [ text (beforeOrAfter "remove2" model) ] ] ]


{-| Cannot read property 'replaceData' of undefined
-}
remove3 : Model -> Html Msg
remove3 model =
    wrap RemoveTarget "remove3" <|
        div [] [ div [ class "target" ] [], text (beforeOrAfter "remove3" model) ]


{-| Cannot set property 'className' of undefined
-}
remove4 : Model -> Html Msg
remove4 model =
    wrap RemoveTarget "remove4" <|
        div [] [ div [ class "target", class (beforeOrAfter "remove4" model) ] [] ]


{-| No error
-}
remove5 : Model -> Html Msg
remove5 model =
    wrap RemoveTarget "remove5" <|
        div [] [ text (beforeOrAfter "remove5" model), div [ class "target" ] [] ]



-- WRAP ".target" into <font>


{-| -}
wrap1 : Model -> Html Msg
wrap1 model =
    wrap WrapTarget "wrap1" <|
        div [] [ div [ class "target" ] [ text (beforeOrAfter "wrap1" model) ] ]


{-| -}
wrap2 : Model -> Html Msg
wrap2 model =
    wrap WrapTarget "wrap2" <|
        div [] [ div [ class "target", class (beforeOrAfter "wrap2" model) ] [] ]


{-| -}
wrap3 : Model -> Html Msg
wrap3 model =
    wrap WrapTarget "wrap3" <|
        div [] [ div [ class "target" ] [], text (beforeOrAfter "wrap3" model) ]


{-| -}
wrap4 : Model -> Html Msg
wrap4 model =
    wrap WrapTarget "wrap4" <|
        div [] [ text (beforeOrAfter "wrap4" model), div [ class "target" ] [] ]


{-| -}
wrap5 : Model -> Html Msg
wrap5 model =
    wrap WrapTarget "wrap5" <|
        div [] [ node "font" [ class "target" ] [ text (beforeOrAfter "wrap5" model) ] ]


{-| Expected:

    <font><font class="target after"></font></font>

or

    <font class="target after"></font>

Actual:

    <font class="target after"><font class="target before"></font></font>

-}
wrap6 : Model -> Html Msg
wrap6 model =
    wrap WrapTarget "wrap6" <|
        div [] [ node "font" [ class "target", class (beforeOrAfter "wrap6" model) ] [] ]


{-| -}
wrap7 : Model -> Html Msg
wrap7 model =
    wrap WrapTarget "wrap7" <|
        div [] [ node "font" [ class "target" ] [], text (beforeOrAfter "wrap7" model) ]


{-| -}
wrap8 : Model -> Html Msg
wrap8 model =
    wrap WrapTarget "wrap8" <|
        div [] [ text (beforeOrAfter "wrap8" model), node "font" [ class "target" ] [] ]



-- REPLACE title of ".target" WITH "break"


{-| This should be safe.
-}
updateAttribute1 : Model -> Html Msg
updateAttribute1 model =
    wrap UpdateAttribute "update-attribute1" <|
        div
            [ class "target"
            , class (beforeOrAfter "update-attribute1" model)
            ]
            [ text (beforeOrAfter "update-attribute1" model) ]


{-| This should be safe.
-}
updateAttribute2 : Model -> Html Msg
updateAttribute2 model =
    wrap UpdateAttribute "update-attribute2" <|
        div
            [ class "target"
            , title "hello"
            , class (beforeOrAfter "update-attribute2" model)
            ]
            [ text (beforeOrAfter "update-attribute2" model) ]


{-| -}
updateAttribute3 : Model -> Html Msg
updateAttribute3 model =
    wrap UpdateAttribute "update-attribute3" <|
        div
            [ class "target"
            , title (beforeOrAfter "update-attribute3" model)
            , class (beforeOrAfter "update-attribute3" model)
            ]
            [ text (beforeOrAfter "update-attribute2" model) ]

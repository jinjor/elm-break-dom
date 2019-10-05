port module Simple.Common exposing (Model, Msg, init, main, noop, onUrlRequest, subscriptions, update, view)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, li, node, text, ul)
import Html.Attributes exposing (class, id, style, title)
import Html.Events exposing (onClick)
import Url


port insertIntoBody : ( String, Int, Int ) -> Cmd msg


port insertBeforeTarget : String -> Cmd msg


port appendToTarget : String -> Cmd msg


port removeTarget : String -> Cmd msg


port wrapTarget : String -> Cmd msg


port updateAttribute : String -> Cmd msg


port done : (String -> msg) -> Sub msg


type Msg
    = NoOp
    | UrlRequest UrlRequest
    | InsertIntoBody Int Int String
    | InsertBeforeTarget String
    | AppendToTarget String
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
    Dict String Int


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
    ( Dict.empty, Cmd.none )


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

        InsertIntoBody top bottom id ->
            ( model, insertIntoBody ( id, top, bottom ) )

        InsertBeforeTarget id ->
            ( model, insertBeforeTarget id )

        AppendToTarget id ->
            ( model, appendToTarget id )

        RemoveTarget id ->
            ( model, removeTarget id )

        WrapTarget id ->
            ( model, wrapTarget id )

        UpdateAttribute id ->
            ( model, updateAttribute id )

        Done id ->
            ( Dict.update id
                (\maybeCount ->
                    case maybeCount of
                        Just n ->
                            Just (n + 1)

                        Nothing ->
                            Just 0
                )
                model
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    done Done


view : Model -> Html Msg
view model =
    ul []
        [ insertIntoBody1 model
        , insertIntoBody2 model
        , insertIntoBody3 model
        , insertIntoBody4 model
        , insertIntoBody5 model
        , insertIntoBody6 model
        , insertIntoBody7 model
        , insertIntoBody8 model
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
        , append1 model
        , append2 model
        , append3 model
        , append4 model
        , append5 model
        , append6 model
        , append7 model
        , append8 model
        , append9 model
        , append10 model
        , append11 model
        , append12 model
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
        , wrap9 model
        , wrap10 model
        , wrap11 model
        , wrap12 model
        , wrap13 model
        , wrap14 model
        , wrap15 model
        , wrap16 model
        , wrap17 model
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
    if Dict.member id model then
        "after"

    else
        "before"



-- INSERT INTO <body>


insertIntoBody1 : Model -> Html Msg
insertIntoBody1 model =
    wrap (InsertIntoBody 0 0) "insert-into-body1" <|
        text (beforeOrAfter "insert-into-body1" model)


insertIntoBody2 : Model -> Html Msg
insertIntoBody2 model =
    wrap (InsertIntoBody 0 1) "insert-into-body2" <|
        text (beforeOrAfter "insert-into-body2" model)


insertIntoBody3 : Model -> Html Msg
insertIntoBody3 model =
    wrap (InsertIntoBody 0 2) "insert-into-body3" <|
        text (beforeOrAfter "insert-into-body3" model)


insertIntoBody4 : Model -> Html Msg
insertIntoBody4 model =
    wrap (InsertIntoBody 1 0) "insert-into-body4" <|
        text (beforeOrAfter "insert-into-body4" model)


insertIntoBody5 : Model -> Html Msg
insertIntoBody5 model =
    wrap (InsertIntoBody 1 1) "insert-into-body5" <|
        text (beforeOrAfter "insert-into-body5" model)


insertIntoBody6 : Model -> Html Msg
insertIntoBody6 model =
    wrap (InsertIntoBody 1 2) "insert-into-body6" <|
        text (beforeOrAfter "insert-into-body6" model)


insertIntoBody7 : Model -> Html Msg
insertIntoBody7 model =
    wrap (InsertIntoBody 2 0) "insert-into-body7" <|
        text (beforeOrAfter "insert-into-body7" model)


insertIntoBody8 : Model -> Html Msg
insertIntoBody8 model =
    wrap (InsertIntoBody 2 1) "insert-into-body8" <|
        text (beforeOrAfter "insert-into-body8" model)



-- INSERT <div>EXTENSION NODE</div> BEFORE ".target"


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



-- APPEND TO ".target"


append1 : Model -> Html Msg
append1 model =
    wrap AppendToTarget "append1" <|
        div [ class "target", class (beforeOrAfter "append1" model) ]
            []


append2 : Model -> Html Msg
append2 model =
    wrap AppendToTarget "append2" <|
        div [ class "target" ]
            [ text (beforeOrAfter "append2" model) ]


append3 : Model -> Html Msg
append3 model =
    wrap AppendToTarget "append3" <|
        div [ class "target" ]
            (if beforeOrAfter "append3" model == "before" then
                []

             else
                [ text "" ]
            )


append4 : Model -> Html Msg
append4 model =
    wrap AppendToTarget "append4" <|
        div [ class "target" ]
            (if beforeOrAfter "append4" model == "before" then
                []

             else
                [ div [ class "e1" ] [ text "" ] ]
            )


append5 : Model -> Html Msg
append5 model =
    wrap AppendToTarget "append5" <|
        div [ class "target" ]
            (if beforeOrAfter "append5" model == "before" then
                []

             else
                [ a [ class "e1" ] [ text "" ] ]
            )


append6 : Model -> Html Msg
append6 model =
    wrap AppendToTarget "append6" <|
        div [ class "target" ]
            (if beforeOrAfter "append6" model == "before" then
                [ text "" ]

             else
                []
            )


append7 : Model -> Html Msg
append7 model =
    wrap AppendToTarget "append7" <|
        div [ class "target" ]
            (if beforeOrAfter "append7" model == "before" then
                [ div [ class "e1" ] [ text "" ] ]

             else
                []
            )


append8 : Model -> Html Msg
append8 model =
    wrap AppendToTarget "append8" <|
        div [ class "target" ]
            (if beforeOrAfter "append8" model == "before" then
                [ a [ class "e1" ] [ text "" ] ]

             else
                []
            )


append9 : Model -> Html Msg
append9 model =
    wrap AppendToTarget "append9" <|
        div [ class "target" ]
            (if beforeOrAfter "append9" model == "before" then
                [ text "", text "" ]

             else
                []
            )


append10 : Model -> Html Msg
append10 model =
    wrap AppendToTarget "append10" <|
        div [ class "target" ]
            (if beforeOrAfter "append10" model == "before" then
                [ div [ class "e1" ] [], div [ class "e2" ] [] ]

             else
                []
            )


append11 : Model -> Html Msg
append11 model =
    wrap AppendToTarget "append11" <|
        div []
            (if beforeOrAfter "append11" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ text "" ]
            )


append12 : Model -> Html Msg
append12 model =
    wrap AppendToTarget "append12" <|
        div []
            (if beforeOrAfter "append12" model == "before" then
                [ div [ class "target" ] [] ]

             else
                []
            )



-- REMOVE ".target"


remove1 : Model -> Html Msg
remove1 model =
    wrap RemoveTarget "remove1" <|
        div [] [ div [ class "target" ] [ text (beforeOrAfter "remove1" model) ] ]


remove2 : Model -> Html Msg
remove2 model =
    wrap RemoveTarget "remove2" <|
        div [] [ div [ class "target" ] [ div [] [ text (beforeOrAfter "remove2" model) ] ] ]


remove3 : Model -> Html Msg
remove3 model =
    wrap RemoveTarget "remove3" <|
        div [] [ div [ class "target" ] [], text (beforeOrAfter "remove3" model) ]


remove4 : Model -> Html Msg
remove4 model =
    wrap RemoveTarget "remove4" <|
        div [] [ div [ class "target", class (beforeOrAfter "remove4" model) ] [] ]


remove5 : Model -> Html Msg
remove5 model =
    wrap RemoveTarget "remove5" <|
        div [] [ text (beforeOrAfter "remove5" model), div [ class "target" ] [] ]



-- WRAP ".target" into <font>


wrap1 : Model -> Html Msg
wrap1 model =
    wrap WrapTarget "wrap1" <|
        div [] [ div [ class "target" ] [ text (beforeOrAfter "wrap1" model) ] ]


wrap2 : Model -> Html Msg
wrap2 model =
    wrap WrapTarget "wrap2" <|
        div [] [ div [ class "target", class (beforeOrAfter "wrap2" model) ] [] ]


wrap3 : Model -> Html Msg
wrap3 model =
    wrap WrapTarget "wrap3" <|
        div [] [ div [ class "target" ] [], text (beforeOrAfter "wrap3" model) ]


wrap4 : Model -> Html Msg
wrap4 model =
    wrap WrapTarget "wrap4" <|
        div [] [ text (beforeOrAfter "wrap4" model), div [ class "target" ] [] ]


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


wrap7 : Model -> Html Msg
wrap7 model =
    wrap WrapTarget "wrap7" <|
        div [] [ node "font" [ class "target" ] [], text (beforeOrAfter "wrap7" model) ]


wrap8 : Model -> Html Msg
wrap8 model =
    wrap WrapTarget "wrap8" <|
        div [] [ text (beforeOrAfter "wrap8" model), node "font" [ class "target" ] [] ]


wrap9 : Model -> Html Msg
wrap9 model =
    wrap WrapTarget "wrap9" <|
        div []
            [ if beforeOrAfter "wrap9" model == "before" then
                div [ class "target" ] []

              else
                text ""
            ]


wrap10 : Model -> Html Msg
wrap10 model =
    wrap WrapTarget "wrap10" <|
        div []
            [ if beforeOrAfter "wrap10" model == "before" then
                div [ class "target" ] []

              else
                a [ class "e1" ] []
            ]


wrap11 : Model -> Html Msg
wrap11 model =
    wrap WrapTarget "wrap11" <|
        div []
            [ if beforeOrAfter "wrap11" model == "before" then
                div [ class "target" ] []

              else
                node "font" [ class "e1" ] [ text "" ]
            ]


wrap12 : Model -> Html Msg
wrap12 model =
    wrap WrapTarget "wrap12" <|
        div []
            (if beforeOrAfter "wrap12" model == "before" then
                [ div [ class "target" ] [] ]

             else
                []
            )


wrap13 : Model -> Html Msg
wrap13 model =
    wrap WrapTarget "wrap13" <|
        div []
            (if beforeOrAfter "wrap13" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ text "1", text "2" ]
            )


wrap14 : Model -> Html Msg
wrap14 model =
    wrap WrapTarget "wrap14" <|
        div []
            (if beforeOrAfter "wrap14" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ a [ class "e1" ] []
                , a [ class "e2" ] []
                ]
            )


wrap15 : Model -> Html Msg
wrap15 model =
    wrap WrapTarget "wrap15" <|
        div []
            (if beforeOrAfter "wrap15" model == "before" then
                [ div [ class "target", class "e1" ] [] ]

             else
                [ div [ class "target", class "e2" ] []
                , a [ class "e3" ] []
                ]
            )


wrap16 : Model -> Html Msg
wrap16 model =
    wrap WrapTarget "wrap16" <|
        div []
            (if beforeOrAfter "wrap16" model == "before" then
                [ div [ class "target", class "e1" ] [] ]

             else
                [ a [ class "e3" ] []
                , div [ class "target", class "e2" ] []
                ]
            )


wrap17 : Model -> Html Msg
wrap17 model =
    wrap WrapTarget "wrap17" <|
        div []
            (if beforeOrAfter "wrap17" model == "before" then
                [ div [ class "target", class "e1" ] [] ]

             else
                [ node "font" [ class "e3" ] []
                , div [ class "target", class "e2" ] []
                ]
            )



-- REPLACE title of ".target" WITH "break"


updateAttribute1 : Model -> Html Msg
updateAttribute1 model =
    wrap UpdateAttribute "update-attribute1" <|
        div
            [ class "target"
            , class (beforeOrAfter "update-attribute1" model)
            ]
            [ text (beforeOrAfter "update-attribute1" model) ]


updateAttribute2 : Model -> Html Msg
updateAttribute2 model =
    wrap UpdateAttribute "update-attribute2" <|
        div
            [ class "target"
            , title "hello"
            , class (beforeOrAfter "update-attribute2" model)
            ]
            [ text (beforeOrAfter "update-attribute2" model) ]


updateAttribute3 : Model -> Html Msg
updateAttribute3 model =
    wrap UpdateAttribute "update-attribute3" <|
        div
            [ class "target"
            , title (beforeOrAfter "update-attribute3" model)
            , class (beforeOrAfter "update-attribute3" model)
            ]
            [ text (beforeOrAfter "update-attribute2" model) ]

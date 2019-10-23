port module Simple.Common exposing (Model, Msg, init, noop, onUrlRequest, subscriptions, update, view, viewInner)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html, a, button, div, li, node, span, text, textarea, ul)
import Html.Attributes exposing (attribute, class, href, id, style, title, value)
import Html.Events exposing (custom, on, onClick, preventDefaultOn, stopPropagationOn)
import Html.Keyed
import Html.Lazy exposing (lazy)
import Json.Decode as D
import VirtualDom exposing (attributeNS, nodeNS)


port event : String -> Cmd msg


port insertIntoBody : ( String, Int, Int ) -> Cmd msg


port insertBeforeTarget : String -> Cmd msg


port appendToTarget : String -> Cmd msg


port removeTarget : String -> Cmd msg


port wrapTarget : String -> Cmd msg


port updateAttribute : ( String, String ) -> Cmd msg


port updateProperty : ( String, String ) -> Cmd msg


port addClass : String -> Cmd msg


port updateStyle : ( String, String ) -> Cmd msg


port removeInsertedNode : String -> Cmd msg


port disableExtension : () -> Cmd msg


port done : (String -> msg) -> Sub msg


type Msg
    = NoOp
    | UrlRequest UrlRequest
    | Event String
    | InsertIntoBody Int Int String
    | InsertBeforeTarget String
    | AppendToTarget String
    | RemoveTarget String
    | WrapTarget String
    | UpdateAttribute String String
    | UpdateProperty String String
    | AddClass String
    | UpdateStyle String String
    | RemoveInsertedNode String
    | Done String
    | Nest Msg
    | DisableExtension


onUrlRequest : UrlRequest -> Msg
onUrlRequest =
    UrlRequest


noop : Msg
noop =
    NoOp


type alias Model =
    Dict String Int


init : () -> ( Model, Cmd Msg )
init _ =
    ( Dict.empty, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UrlRequest urlRequest ->
            case urlRequest of
                Internal url ->
                    case String.split "/" url.path of
                        "" :: "InsertIntoBody" :: id :: [] ->
                            update (InsertIntoBody 1 1 id) model

                        "" :: "InsertBeforeTarget" :: id :: [] ->
                            update (InsertBeforeTarget id) model

                        "" :: "AppendToTarget" :: id :: [] ->
                            update (AppendToTarget id) model

                        "" :: "RemoveTarget" :: id :: [] ->
                            update (RemoveTarget id) model

                        "" :: "WrapTarget" :: id :: [] ->
                            update (WrapTarget id) model

                        "" :: "UpdateAttribute" :: id :: [] ->
                            update (UpdateAttribute "title" id) model

                        "" :: "UpdateProperty" :: id :: [] ->
                            update (UpdateAttribute "value" id) model

                        "" :: "AddClass" :: id :: [] ->
                            update (AddClass id) model

                        "" :: "UpdateStyle" :: id :: [] ->
                            update (UpdateStyle "color" id) model

                        "" :: "RemoveInsertedNode" :: id :: [] ->
                            update (RemoveInsertedNode id) model

                        _ ->
                            ( model, Cmd.none )

                External url ->
                    ( model, Nav.load url )

        Event s ->
            ( model, event s )

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

        UpdateAttribute key id ->
            ( model, updateAttribute ( id, key ) )

        UpdateProperty key id ->
            ( model, updateProperty ( id, key ) )

        AddClass id ->
            ( model, addClass id )

        UpdateStyle key id ->
            ( model, updateStyle ( id, key ) )

        RemoveInsertedNode id ->
            ( model, removeInsertedNode id )

        Done id ->
            ( Dict.update id
                (\maybeCount ->
                    case maybeCount of
                        Just n ->
                            Just (n + 1)

                        Nothing ->
                            Just 1
                )
                model
            , Cmd.none
            )

        Nest msg_ ->
            update msg_ model

        DisableExtension ->
            ( model, disableExtension () )


subscriptions : Model -> Sub Msg
subscriptions _ =
    done Done


view : Model -> List (Html Msg)
view model =
    if beforeOrAfter "boundary1" model == "after" || beforeOrAfter "boundary7" model == "after" then
        [ text "a", viewInner model ]

    else if beforeOrAfter "boundary2" model == "after" || beforeOrAfter "boundary8" model == "after" then
        [ div [] [], viewInner model ]

    else if beforeOrAfter "boundary3" model == "after" || beforeOrAfter "boundary9" model == "after" then
        [ viewInner model, text "b" ]

    else if beforeOrAfter "boundary4" model == "after" || beforeOrAfter "boundary10" model == "after" then
        [ viewInner model, div [] [] ]

    else if beforeOrAfter "boundary5" model == "after" || beforeOrAfter "boundary11" model == "after" then
        [ text "c" ]

    else if beforeOrAfter "boundary6" model == "after" || beforeOrAfter "boundary12" model == "after" then
        []

    else
        [ viewInner model ]


viewInner : Model -> Html Msg
viewInner model =
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
        , insert22 model
        , insert23 model
        , insert24 model
        , insert25 model
        , insert26 model
        , insert27 model
        , insert28 model
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
        , updateAttribute4 model
        , updateAttribute5 model
        , updateAttribute6 model
        , updateAttribute7 model
        , updateAttribute8 model
        , updateAttribute9 model
        , updateProperty1 model
        , updateProperty2 model
        , updateProperty3 model
        , updateProperty4 model
        , updateProperty5 model
        , updateProperty6 model
        , updateProperty7 model
        , updateProperty8 model
        , addClass1 model
        , addClass2 model
        , updateStyle1 model
        , updateStyle2 model
        , updateStyle3 model
        , updateStyle4 model
        , updateStyle5 model
        , event1 model
        , event2 model
        , event3 model
        , event4 model
        , event5 model
        , event6 model
        , event7 model
        , event8 model
        , event9 model
        , event10 model
        , event11 model
        , event12 model
        , event13 model
        , event14 model
        , event15 model
        , event16 model
        , event17 model
        , event18 model
        , event19 model
        , event20 model
        , event21 model
        , event22 model
        , event23 model
        , event24 model
        , event25 model
        , event26 model
        , event27 model
        , event28 model
        , keyed1 model
        , keyed2 model
        , keyed3 model
        , keyed4 model
        , keyed5 model
        , keyed6 model
        , keyed7 model
        , keyed8 model
        , keyed9 model
        , keyed10 model
        , keyed11 model
        , keyed12 model
        , keyed13 model
        , keyed14 model
        , keyed15 model
        , keyed16 model
        , keyed17 model
        , keyed18 model
        , keyed19 model
        , keyed20 model
        , keyed21 model
        , keyed22 model
        , keyed23 model
        , keyed24 model
        , keyed25 model
        , keyed26 model
        , keyed27 model
        , keyed28 model
        , keyed29 model
        , keyed30 model
        , lazy1 model
        , lazy2 model
        , lazy3 model
        , lazy4 model
        , lazy5 model
        , lazy6 model
        , lazy7 model
        , lazy8 model
        , lazy9 model
        , lazy10 model
        , lazy11 model
        , lazy12 model
        , lazy13 model
        , lazy14 model
        , lazy15 model
        , lazy16 model
        , lazy17 model
        , lazy18 model
        , lazy19 model
        , lazy20 model
        , route1 model
        , route2 model
        , route3 model
        , route4 model
        , route5 model
        , route6 model
        , route7 model
        , route8 model
        , route9 model
        , route10 model
        , edge1 model
        , boundary1 model
        , boundary2 model
        , boundary3 model
        , boundary4 model
        , boundary5 model
        , boundary6 model
        , boundary7 model
        , boundary8 model
        , boundary9 model
        , boundary10 model
        , boundary11 model
        , boundary12 model
        , div []
            [ button [ id "disable-extension", onClick DisableExtension ] [ text "disable extension" ]
            ]
        ]



-- UTILS


wrap : Model -> (String -> Msg) -> String -> Html Msg -> Html Msg
wrap model toMsg id_ content =
    li
        [ id id_
        , class ("count-" ++ count id_ model)
        , class "wrapper"
        , style "padding" "20px"
        ]
        [ content
        , button
            [ onClick (toMsg id_)
            , class "break"
            ]
            [ text id_ ]
        , button
            [ onClick (RemoveInsertedNode id_)
            , class "remove-inserted-node"
            ]
            [ text id_ ]
        ]


beforeOrAfter : String -> Model -> String
beforeOrAfter id model =
    if Dict.member id model then
        "after"

    else
        "before"


count : String -> Model -> String
count id model =
    countAsInt id model
        |> String.fromInt


countAsInt : String -> Model -> Int
countAsInt id model =
    Dict.get id model
        |> Maybe.withDefault 0


viewText : String -> Html msg
viewText s =
    text s



-- INSERT INTO <body>


insertIntoBody1 : Model -> Html Msg
insertIntoBody1 model =
    wrap model (InsertIntoBody 0 0) "insert-into-body1" <|
        text (beforeOrAfter "insert-into-body1" model)


insertIntoBody2 : Model -> Html Msg
insertIntoBody2 model =
    wrap model (InsertIntoBody 0 1) "insert-into-body2" <|
        text (beforeOrAfter "insert-into-body2" model)


insertIntoBody3 : Model -> Html Msg
insertIntoBody3 model =
    wrap model (InsertIntoBody 0 2) "insert-into-body3" <|
        text (beforeOrAfter "insert-into-body3" model)


insertIntoBody4 : Model -> Html Msg
insertIntoBody4 model =
    wrap model (InsertIntoBody 1 0) "insert-into-body4" <|
        text (beforeOrAfter "insert-into-body4" model)


insertIntoBody5 : Model -> Html Msg
insertIntoBody5 model =
    wrap model (InsertIntoBody 1 1) "insert-into-body5" <|
        text (beforeOrAfter "insert-into-body5" model)


insertIntoBody6 : Model -> Html Msg
insertIntoBody6 model =
    wrap model (InsertIntoBody 1 2) "insert-into-body6" <|
        text (beforeOrAfter "insert-into-body6" model)


insertIntoBody7 : Model -> Html Msg
insertIntoBody7 model =
    wrap model (InsertIntoBody 2 0) "insert-into-body7" <|
        text (beforeOrAfter "insert-into-body7" model)


insertIntoBody8 : Model -> Html Msg
insertIntoBody8 model =
    wrap model (InsertIntoBody 2 1) "insert-into-body8" <|
        text (beforeOrAfter "insert-into-body8" model)



-- INSERT <div>EXTENSION NODE</div> BEFORE ".target"


insert1 : Model -> Html Msg
insert1 model =
    wrap model InsertBeforeTarget "insert1" <|
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
    wrap model InsertBeforeTarget "insert2" <|
        div [] [ div [ class "target" ] [ text (beforeOrAfter "insert2" model) ] ]


insert3 : Model -> Html Msg
insert3 model =
    wrap model InsertBeforeTarget "insert3" <|
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
    wrap model InsertBeforeTarget "insert4" <|
        div [] [ div [ class "target", class (beforeOrAfter "insert4" model) ] [] ]


insert5 : Model -> Html Msg
insert5 model =
    wrap model InsertBeforeTarget "insert5" <|
        div [] [ text (beforeOrAfter "insert5" model), div [ class "target" ] [] ]


insert6 : Model -> Html Msg
insert6 model =
    wrap model InsertBeforeTarget "insert6" <|
        div []
            [ if beforeOrAfter "insert6" model == "before" then
                text "1"

              else
                div [ class "e1" ] []
            , div [ class "target" ] []
            ]


insert7 : Model -> Html Msg
insert7 model =
    wrap model InsertBeforeTarget "insert7" <|
        div []
            [ if beforeOrAfter "insert7" model == "before" then
                div [ class "e1" ] []

              else
                text ""
            , div [ class "target" ] []
            ]


insert8 : Model -> Html Msg
insert8 model =
    wrap model InsertBeforeTarget "insert8" <|
        div []
            (if beforeOrAfter "insert8" model == "before" then
                [ div [ class "target" ] [] ]

             else
                []
            )


insert9 : Model -> Html Msg
insert9 model =
    wrap model InsertBeforeTarget "insert9" <|
        div []
            (if beforeOrAfter "insert9" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ text "", div [ class "target" ] [] ]
            )


insert10 : Model -> Html Msg
insert10 model =
    wrap model InsertBeforeTarget "insert10" <|
        div []
            (if beforeOrAfter "insert10" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ div [ class "e1" ] [], div [ class "target" ] [] ]
            )


insert11 : Model -> Html Msg
insert11 model =
    wrap model InsertBeforeTarget "insert11" <|
        div []
            (if beforeOrAfter "insert11" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ a [ class "e1" ] [], div [ class "target" ] [] ]
            )


insert12 : Model -> Html Msg
insert12 model =
    wrap model InsertBeforeTarget "insert12" <|
        div []
            (if beforeOrAfter "insert12" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ a [ class "e1" ] [] ]
            )


insert13 : Model -> Html Msg
insert13 model =
    wrap model InsertBeforeTarget "insert13" <|
        div []
            (if beforeOrAfter "insert13" model == "before" then
                [ div [ class "e1" ] [], div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [] ]
            )


insert14 : Model -> Html Msg
insert14 model =
    wrap model InsertBeforeTarget "insert14" <|
        div []
            (if beforeOrAfter "insert14" model == "before" then
                [ a [ class "e1" ] [], div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [] ]
            )


insert15 : Model -> Html Msg
insert15 model =
    wrap model InsertBeforeTarget "insert15" <|
        div []
            (if beforeOrAfter "insert15" model == "before" then
                [ text "", div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [] ]
            )


insert16 : Model -> Html Msg
insert16 model =
    wrap model InsertBeforeTarget "insert16" <|
        div []
            (if beforeOrAfter "insert16" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [], text "" ]
            )


insert17 : Model -> Html Msg
insert17 model =
    wrap model InsertBeforeTarget "insert17" <|
        div []
            (if beforeOrAfter "insert17" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [], div [ class "e1" ] [] ]
            )


insert18 : Model -> Html Msg
insert18 model =
    wrap model InsertBeforeTarget "insert18" <|
        div []
            (if beforeOrAfter "insert18" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ div [ class "target" ] [], a [ class "e1" ] [] ]
            )


insert19 : Model -> Html Msg
insert19 model =
    wrap model InsertBeforeTarget "insert19" <|
        div []
            (if beforeOrAfter "insert19" model == "before" then
                [ div [ class "target" ] [], div [ class "e1" ] [] ]

             else
                [ div [ class "target" ] [] ]
            )


insert20 : Model -> Html Msg
insert20 model =
    wrap model InsertBeforeTarget "insert20" <|
        div []
            (if beforeOrAfter "insert20" model == "before" then
                [ div [ class "target" ] [], a [ class "e1" ] [] ]

             else
                [ div [ class "target" ] [] ]
            )


insert21 : Model -> Html Msg
insert21 model =
    wrap model InsertBeforeTarget "insert21" <|
        div []
            (if beforeOrAfter "insert21" model == "before" then
                [ div [ class "target" ] [], text "" ]

             else
                [ div [ class "target" ] [] ]
            )


insert22 : Model -> Html Msg
insert22 model =
    wrap model InsertBeforeTarget "insert22" <|
        Html.map identity <|
            div [] [ div [ class "target" ] [ text (beforeOrAfter "insert22" model) ] ]


insert23 : Model -> Html Msg
insert23 model =
    wrap model InsertBeforeTarget "insert23" <|
        Html.map identity <|
            div [] [ div [ class "target", class (beforeOrAfter "insert23" model) ] [] ]


insert24 : Model -> Html Msg
insert24 model =
    wrap model InsertBeforeTarget "insert24" <|
        div []
            [ Html.map identity <|
                div [ class "target", class (beforeOrAfter "insert24" model) ] []
            ]


insert25 : Model -> Html Msg
insert25 model =
    wrap model InsertBeforeTarget "insert25" <|
        div []
            [ Html.map identity <|
                div [ class "target" ] []
            , text (beforeOrAfter "insert25" model)
            ]


insert26 : Model -> Html Msg
insert26 model =
    wrap model InsertBeforeTarget "insert26" <|
        div []
            [ text (beforeOrAfter "insert26" model)
            , Html.map identity <|
                div [ class "target" ] []
            ]


insert27 : Model -> Html Msg
insert27 model =
    wrap model InsertBeforeTarget "insert27" <|
        div []
            [ Html.map identity (text "")
            , div [ class "target", class (beforeOrAfter "insert27" model) ] []
            ]


insert28 : Model -> Html Msg
insert28 model =
    wrap model InsertBeforeTarget "insert28" <|
        div []
            [ div [ class "target", class (beforeOrAfter "insert28" model) ] []
            , Html.map identity (text "")
            ]



-- APPEND TO ".target"


append1 : Model -> Html Msg
append1 model =
    wrap model AppendToTarget "append1" <|
        div [ class "target", class (beforeOrAfter "append1" model) ]
            []


append2 : Model -> Html Msg
append2 model =
    wrap model AppendToTarget "append2" <|
        div [ class "target" ]
            [ text (beforeOrAfter "append2" model) ]


append3 : Model -> Html Msg
append3 model =
    wrap model AppendToTarget "append3" <|
        div [ class "target" ]
            (if beforeOrAfter "append3" model == "before" then
                []

             else
                [ text "" ]
            )


append4 : Model -> Html Msg
append4 model =
    wrap model AppendToTarget "append4" <|
        div [ class "target" ]
            (if beforeOrAfter "append4" model == "before" then
                []

             else
                [ div [ class "e1" ] [ text "" ] ]
            )


append5 : Model -> Html Msg
append5 model =
    wrap model AppendToTarget "append5" <|
        div [ class "target" ]
            (if beforeOrAfter "append5" model == "before" then
                []

             else
                [ a [ class "e1" ] [ text "" ] ]
            )


append6 : Model -> Html Msg
append6 model =
    wrap model AppendToTarget "append6" <|
        div [ class "target" ]
            (if beforeOrAfter "append6" model == "before" then
                [ text "" ]

             else
                []
            )


append7 : Model -> Html Msg
append7 model =
    wrap model AppendToTarget "append7" <|
        div [ class "target" ]
            (if beforeOrAfter "append7" model == "before" then
                [ div [ class "e1" ] [ text "" ] ]

             else
                []
            )


append8 : Model -> Html Msg
append8 model =
    wrap model AppendToTarget "append8" <|
        div [ class "target" ]
            (if beforeOrAfter "append8" model == "before" then
                [ a [ class "e1" ] [ text "" ] ]

             else
                []
            )


append9 : Model -> Html Msg
append9 model =
    wrap model AppendToTarget "append9" <|
        div [ class "target" ]
            (if beforeOrAfter "append9" model == "before" then
                [ text "", text "" ]

             else
                []
            )


append10 : Model -> Html Msg
append10 model =
    wrap model AppendToTarget "append10" <|
        div [ class "target" ]
            (if beforeOrAfter "append10" model == "before" then
                [ div [ class "e1" ] [], div [ class "e2" ] [] ]

             else
                []
            )


append11 : Model -> Html Msg
append11 model =
    wrap model AppendToTarget "append11" <|
        div []
            (if beforeOrAfter "append11" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ text "" ]
            )


append12 : Model -> Html Msg
append12 model =
    wrap model AppendToTarget "append12" <|
        div []
            (if beforeOrAfter "append12" model == "before" then
                [ div [ class "target" ] [] ]

             else
                []
            )



-- REMOVE ".target"


remove1 : Model -> Html Msg
remove1 model =
    wrap model RemoveTarget "remove1" <|
        div [] [ div [ class "target" ] [ text (beforeOrAfter "remove1" model) ] ]


remove2 : Model -> Html Msg
remove2 model =
    wrap model RemoveTarget "remove2" <|
        div [] [ div [ class "target" ] [ div [] [ text (beforeOrAfter "remove2" model) ] ] ]


remove3 : Model -> Html Msg
remove3 model =
    wrap model RemoveTarget "remove3" <|
        div [] [ div [ class "target" ] [], text (beforeOrAfter "remove3" model) ]


remove4 : Model -> Html Msg
remove4 model =
    wrap model RemoveTarget "remove4" <|
        div [] [ div [ class "target", class (beforeOrAfter "remove4" model) ] [] ]


remove5 : Model -> Html Msg
remove5 model =
    wrap model RemoveTarget "remove5" <|
        div [] [ text (beforeOrAfter "remove5" model), div [ class "target" ] [] ]



-- WRAP ".target" into <font>


wrap1 : Model -> Html Msg
wrap1 model =
    wrap model WrapTarget "wrap1" <|
        div [] [ div [ class "target" ] [ text (beforeOrAfter "wrap1" model) ] ]


wrap2 : Model -> Html Msg
wrap2 model =
    wrap model WrapTarget "wrap2" <|
        div [] [ div [ class "target", class (beforeOrAfter "wrap2" model) ] [] ]


wrap3 : Model -> Html Msg
wrap3 model =
    wrap model WrapTarget "wrap3" <|
        div [] [ div [ class "target" ] [], text (beforeOrAfter "wrap3" model) ]


wrap4 : Model -> Html Msg
wrap4 model =
    wrap model WrapTarget "wrap4" <|
        div [] [ text (beforeOrAfter "wrap4" model), div [ class "target" ] [] ]


wrap5 : Model -> Html Msg
wrap5 model =
    wrap model WrapTarget "wrap5" <|
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
    wrap model WrapTarget "wrap6" <|
        div [] [ node "font" [ class "target", class (beforeOrAfter "wrap6" model) ] [] ]


wrap7 : Model -> Html Msg
wrap7 model =
    wrap model WrapTarget "wrap7" <|
        div [] [ node "font" [ class "target" ] [], text (beforeOrAfter "wrap7" model) ]


wrap8 : Model -> Html Msg
wrap8 model =
    wrap model WrapTarget "wrap8" <|
        div [] [ text (beforeOrAfter "wrap8" model), node "font" [ class "target" ] [] ]


wrap9 : Model -> Html Msg
wrap9 model =
    wrap model WrapTarget "wrap9" <|
        div []
            [ if beforeOrAfter "wrap9" model == "before" then
                div [ class "target" ] []

              else
                text ""
            ]


wrap10 : Model -> Html Msg
wrap10 model =
    wrap model WrapTarget "wrap10" <|
        div []
            [ if beforeOrAfter "wrap10" model == "before" then
                div [ class "target" ] []

              else
                a [ class "e1" ] []
            ]


wrap11 : Model -> Html Msg
wrap11 model =
    wrap model WrapTarget "wrap11" <|
        div []
            [ if beforeOrAfter "wrap11" model == "before" then
                div [ class "target" ] []

              else
                node "font" [ class "e1" ] [ text "" ]
            ]


wrap12 : Model -> Html Msg
wrap12 model =
    wrap model WrapTarget "wrap12" <|
        div []
            (if beforeOrAfter "wrap12" model == "before" then
                [ div [ class "target" ] [] ]

             else
                []
            )


wrap13 : Model -> Html Msg
wrap13 model =
    wrap model WrapTarget "wrap13" <|
        div []
            (if beforeOrAfter "wrap13" model == "before" then
                [ div [ class "target" ] [] ]

             else
                [ text "1", text "2" ]
            )


wrap14 : Model -> Html Msg
wrap14 model =
    wrap model WrapTarget "wrap14" <|
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
    wrap model WrapTarget "wrap15" <|
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
    wrap model WrapTarget "wrap16" <|
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
    wrap model WrapTarget "wrap17" <|
        div []
            (if beforeOrAfter "wrap17" model == "before" then
                [ div [ class "target", class "e1" ] [] ]

             else
                [ node "font" [ class "e3" ] []
                , div [ class "target", class "e2" ] []
                ]
            )



-- REPLACE title of ".target" WITH ".ext"


updateAttribute1 : Model -> Html Msg
updateAttribute1 model =
    wrap model (UpdateAttribute "title") "update-attribute1" <|
        div
            [ class "target"
            , class (beforeOrAfter "update-attribute1" model)
            ]
            [ text (beforeOrAfter "update-attribute1" model) ]


updateAttribute2 : Model -> Html Msg
updateAttribute2 model =
    wrap model (UpdateAttribute "title") "update-attribute2" <|
        div
            [ class "target"
            , title "hello"
            , class (beforeOrAfter "update-attribute2" model)
            ]
            [ text (beforeOrAfter "update-attribute2" model) ]


updateAttribute3 : Model -> Html Msg
updateAttribute3 model =
    wrap model (UpdateAttribute "title") "update-attribute3" <|
        div
            [ class "target"
            , title (beforeOrAfter "update-attribute3" model)
            , class (beforeOrAfter "update-attribute3" model)
            ]
            [ text (beforeOrAfter "update-attribute3" model) ]


updateAttribute4 : Model -> Html Msg
updateAttribute4 model =
    wrap model (UpdateAttribute "title") "update-attribute4" <|
        div
            [ class "target"
            , attribute "title" "hello"
            , class (beforeOrAfter "update-attribute4" model)
            ]
            [ text (beforeOrAfter "update-attribute4" model) ]


updateAttribute5 : Model -> Html Msg
updateAttribute5 model =
    wrap model (UpdateAttribute "title") "update-attribute5" <|
        div
            [ class "target"
            , attribute "title" (beforeOrAfter "update-attribute5" model)
            , class (beforeOrAfter "update-attribute5" model)
            ]
            [ text (beforeOrAfter "update-attribute5" model) ]


updateAttribute6 : Model -> Html Msg
updateAttribute6 model =
    wrap model (UpdateAttribute "title") "update-attribute6" <|
        div
            [ class "target"
            , if beforeOrAfter "update-attribute6" model == "before" then
                title "hello"

              else
                class ""
            , class (beforeOrAfter "update-attribute6" model)
            ]
            [ text (beforeOrAfter "update-attribute6" model) ]


updateAttribute7 : Model -> Html Msg
updateAttribute7 model =
    wrap model (UpdateAttribute "title") "update-attribute7" <|
        div
            [ class "target"
            , if beforeOrAfter "update-attribute7" model == "before" then
                class ""

              else
                title "hello"
            , class (beforeOrAfter "update-attribute7" model)
            ]
            [ text (beforeOrAfter "update-attribute7" model) ]


updateAttribute8 : Model -> Html Msg
updateAttribute8 model =
    wrap model (UpdateAttribute "class") "update-attribute8" <|
        div
            [ class "target"
            , class ("e" ++ count "update-attribute8" model)
            ]
            [ text (count "update-attribute8" model) ]


updateAttribute9 : Model -> Html Msg
updateAttribute9 model =
    wrap model (UpdateAttribute "data-xxx") "update-attribute9" <|
        div
            [ class "target"
            , class ("e" ++ count "update-attribute9" model)
            ]
            [ text (count "update-attribute9" model) ]



-- UPDATE property


updateProperty1 : Model -> Html Msg
updateProperty1 model =
    wrap model (UpdateProperty "value") "update-property1" <|
        textarea
            [ class "target"
            , class (beforeOrAfter "update-property1" model)
            ]
            [ text (beforeOrAfter "update-property1" model) ]


updateProperty2 : Model -> Html Msg
updateProperty2 model =
    wrap model (UpdateProperty "value") "update-property2" <|
        textarea
            [ class "target"
            , value "hello"
            , class (beforeOrAfter "update-property2" model)
            ]
            [ text (beforeOrAfter "update-property2" model) ]


updateProperty3 : Model -> Html Msg
updateProperty3 model =
    wrap model (UpdateProperty "value") "update-property3" <|
        textarea
            [ class "target"
            , value (beforeOrAfter "update-property3" model)
            , class (beforeOrAfter "update-property3" model)
            ]
            [ text (beforeOrAfter "update-property3" model) ]


updateProperty4 : Model -> Html Msg
updateProperty4 model =
    wrap model (UpdateProperty "value") "update-property4" <|
        textarea
            [ class "target"
            , attribute "value" "hello"
            , class (beforeOrAfter "update-property4" model)
            ]
            [ text (beforeOrAfter "update-property4" model) ]


updateProperty5 : Model -> Html Msg
updateProperty5 model =
    wrap model (UpdateProperty "value") "update-property5" <|
        textarea
            [ class "target"
            , attribute "value" (beforeOrAfter "update-property5" model)
            , class (beforeOrAfter "update-property5" model)
            ]
            [ text (beforeOrAfter "update-property5" model) ]


updateProperty6 : Model -> Html Msg
updateProperty6 model =
    wrap model (UpdateProperty "value") "update-property6" <|
        textarea
            [ class "target"
            , if beforeOrAfter "update-property6" model == "before" then
                value "hello"

              else
                class ""
            , class (beforeOrAfter "update-property6" model)
            ]
            [ text (beforeOrAfter "update-property6" model) ]


updateProperty7 : Model -> Html Msg
updateProperty7 model =
    wrap model (UpdateProperty "value") "update-property7" <|
        textarea
            [ class "target"
            , if beforeOrAfter "update-property7" model == "before" then
                class ""

              else
                value "hello"
            , class (beforeOrAfter "update-property7" model)
            ]
            [ text (beforeOrAfter "update-property7" model) ]


updateProperty8 : Model -> Html Msg
updateProperty8 model =
    wrap model (UpdateProperty "className") "update-property8" <|
        textarea
            [ class "target"
            , class ("e" ++ count "update-property8" model)
            ]
            [ text (count "update-property8" model) ]



-- ADD class "ext"


addClass1 : Model -> Html Msg
addClass1 model =
    wrap model AddClass "add-class1" <|
        div
            [ class "target"
            , class (count "add-class1" model)
            ]
            [ text (count "add-class1" model) ]


addClass2 : Model -> Html Msg
addClass2 model =
    wrap model AddClass "add-class2" <|
        div
            (if beforeOrAfter "add-class2" model == "before" then
                [ class "target" ]

             else
                []
            )
            [ text (count "add-class2" model) ]



-- UPDATE STYLE


updateStyle1 : Model -> Html Msg
updateStyle1 model =
    wrap model (UpdateStyle "color") "update-style1" <|
        div
            [ class "target"
            , class (count "update-style1" model)
            ]
            [ text (count "update-style1" model) ]


updateStyle2 : Model -> Html Msg
updateStyle2 model =
    wrap model (UpdateStyle "color") "update-style2" <|
        div
            [ class "target"
            , style "padding" (count "update-style2" model)
            ]
            [ text (count "update-style2" model) ]


updateStyle3 : Model -> Html Msg
updateStyle3 model =
    wrap model (UpdateStyle "color") "update-style3" <|
        div
            [ class "target"
            , style "color" (count "update-style3" model)
            ]
            [ text (count "update-style3" model) ]


updateStyle4 : Model -> Html Msg
updateStyle4 model =
    wrap model (UpdateStyle "color") "update-style4" <|
        div
            [ class "target"
            , if beforeOrAfter "update-style4" model == "before" then
                class (count "update-style4" model)

              else
                style "color" (count "update-style4" model)
            ]
            [ text (count "update-style4" model) ]


updateStyle5 : Model -> Html Msg
updateStyle5 model =
    wrap model (UpdateStyle "color") "update-style5" <|
        div
            [ class "target"
            , if beforeOrAfter "update-style5" model == "before" then
                style "color" (count "update-style5" model)

              else
                class (count "update-style5" model)
            ]
            [ text (count "update-style5" model) ]



-- EVENTS


event1 : Model -> Html Msg
event1 model =
    wrap model InsertBeforeTarget "event1" <|
        div []
            [ span
                [ class "target"
                , class "button"
                , onClick (Event "a")
                ]
                [ text (beforeOrAfter "event1" model) ]
            ]


event2 : Model -> Html Msg
event2 model =
    wrap model InsertBeforeTarget "event2" <|
        div []
            [ span
                [ class "target"
                , class "button"
                , Html.Attributes.map Event (onClick "a")
                ]
                [ text (beforeOrAfter "event2" model) ]
            ]


event3 : Model -> Html Msg
event3 model =
    wrap model InsertBeforeTarget "event3" <|
        div []
            [ Html.map Event <|
                span
                    [ class "target"
                    , class "button"
                    , onClick "a"
                    ]
                    [ text (beforeOrAfter "event3" model) ]
            ]


event4 : Model -> Html Msg
event4 model =
    wrap model InsertBeforeTarget "event4" <|
        div []
            [ span
                [ class "target"
                , class "button"
                , onClick (Event (beforeOrAfter "event4" model))
                ]
                []
            ]


event5 : Model -> Html Msg
event5 model =
    wrap model InsertBeforeTarget "event5" <|
        div []
            [ span
                [ class "target"
                , class "button"
                , Html.Attributes.map Event (onClick (beforeOrAfter "event5" model))
                ]
                []
            ]


event6 : Model -> Html Msg
event6 model =
    wrap model InsertBeforeTarget "event6" <|
        div []
            [ Html.map Event <|
                span
                    [ class "target"
                    , class "button"
                    , onClick (beforeOrAfter "event6" model)
                    ]
                    []
            ]


event7 : Model -> Html Msg
event7 model =
    wrap model InsertBeforeTarget "event7" <|
        div []
            [ span
                [ class "target"
                , class "button"
                , Html.Attributes.map (\s -> Event s) <|
                    onClick (beforeOrAfter "event7" model)
                ]
                []
            ]


event8 : Model -> Html Msg
event8 model =
    wrap model InsertBeforeTarget "event8" <|
        div []
            [ Html.map (\s -> Event s) <|
                span
                    [ class "target"
                    , class "button"
                    , onClick (beforeOrAfter "event8" model)
                    ]
                    []
            ]


event9 : Model -> Html Msg
event9 model =
    wrap model InsertBeforeTarget "event9" <|
        div [ class (beforeOrAfter "event9" model) ]
            [ span
                [ class "button"
                , class "prev"
                , onClick (Event "prev")
                ]
                []
            , span
                [ class "target"
                , class "button"
                , onClick (Event "target")
                ]
                []
            , span
                [ class "button"
                , class "next"
                , onClick (Event "next")
                ]
                []
            ]


event10 : Model -> Html Msg
event10 model =
    wrap model InsertBeforeTarget "event10" <|
        div []
            [ span
                [ class "button"
                , class "prev"
                , onClick (Event "prev")
                ]
                [ text (count "event10" model) ]
            , span
                [ class "target"
                , class "button"
                , onClick (Event "target")
                ]
                [ text (count "event10" model) ]
            , span
                [ class "button"
                , class "next"
                , onClick (Event "next")
                ]
                [ text (count "event10" model) ]
            ]


event11 : Model -> Html Msg
event11 model =
    wrap model InsertBeforeTarget "event11" <|
        Html.Keyed.node "div"
            [ class (beforeOrAfter "event11" model) ]
            [ ( "0"
              , span
                    [ class "button"
                    , class "prev"
                    , onClick (Event "prev")
                    ]
                    []
              )
            , ( "1"
              , span
                    [ class "target"
                    , class "button"
                    , onClick (Event "target")
                    ]
                    []
              )
            , ( "2"
              , span
                    [ class "button"
                    , class "next"
                    , onClick (Event "next")
                    ]
                    []
              )
            ]


event12 : Model -> Html Msg
event12 model =
    wrap model InsertBeforeTarget "event12" <|
        Html.Keyed.node "div"
            []
            [ ( "0"
              , span
                    [ class "button"
                    , class "prev"
                    , onClick (Event "prev")
                    ]
                    [ text (count "event12" model) ]
              )
            , ( "1"
              , span
                    [ class "target"
                    , class "button"
                    , onClick (Event "target")
                    ]
                    [ text (count "event12" model) ]
              )
            , ( "2"
              , span
                    [ class "button"
                    , class "next"
                    , onClick (Event "next")
                    ]
                    [ text (count "event12" model) ]
              )
            ]


event13 : Model -> Html Msg
event13 model =
    wrap model InsertBeforeTarget "event13" <|
        div [ class (beforeOrAfter "event13" model) ]
            [ lazy
                (\_ ->
                    span
                        [ class "button"
                        , class "prev"
                        , onClick (Event "prev")
                        ]
                        []
                )
                ()
            , lazy
                (\_ ->
                    span
                        [ class "target"
                        , class "button"
                        , onClick (Event "target")
                        ]
                        []
                )
                ()
            , lazy
                (\_ ->
                    span
                        [ class "button"
                        , class "next"
                        , onClick (Event "next")
                        ]
                        [ lazy viewText "" ]
                )
                ()
            ]


event14 : Model -> Html Msg
event14 model =
    wrap model InsertBeforeTarget "event14" <|
        div []
            [ span
                [ class "button"
                , class "prev"
                , onClick (Event "prev")
                ]
                [ lazy viewText (count "event14" model) ]
            , span
                [ class "target"
                , class "button"
                , onClick (Event "target")
                ]
                [ lazy viewText (count "event14" model) ]
            , span
                [ class "button"
                , class "next"
                , onClick (Event "next")
                ]
                [ lazy viewText (count "event14" model) ]
            ]


event15 : Model -> Html Msg
event15 model =
    wrap model WrapTarget "event15" <|
        div []
            [ span
                [ class "target"
                , class "button"
                , Html.Attributes.map Event <|
                    onClick (beforeOrAfter "event15" model)
                ]
                []
            ]


event16 : Model -> Html Msg
event16 model =
    wrap model WrapTarget "event16" <|
        div []
            [ Html.map Event <|
                span
                    [ class "target"
                    , class "button"
                    , onClick (beforeOrAfter "event16" model)
                    ]
                    []
            ]


event17 : Model -> Html Msg
event17 model =
    wrap model WrapTarget "event17" <|
        div []
            [ span
                [ class "target"
                , class "button"
                , Html.Attributes.map (\s -> Event s) <|
                    onClick (beforeOrAfter "event17" model)
                ]
                []
            ]


event18 : Model -> Html Msg
event18 model =
    wrap model WrapTarget "event18" <|
        div []
            [ Html.map (\s -> Event s) <|
                span
                    [ class "target"
                    , class "button"
                    , onClick (beforeOrAfter "event18" model)
                    ]
                    []
            ]


event19 : Model -> Html Msg
event19 model =
    wrap model RemoveTarget "event19" <|
        div []
            [ span
                [ class "target"
                , class "button"
                , onClick (Event (beforeOrAfter "event19" model))
                ]
                []
            ]


event20 : Model -> Html Msg
event20 model =
    wrap model InsertBeforeTarget "event20" <|
        div []
            [ span
                [ class "target"
                , class "button"
                , if beforeOrAfter "event20" model == "before" then
                    onClick (Event "a")

                  else
                    class ""
                ]
                []
            ]


event21 : Model -> Html Msg
event21 model =
    wrap model InsertBeforeTarget "event21" <|
        div []
            [ span
                [ class "target"
                , class "button"
                , if beforeOrAfter "event21" model == "before" then
                    onClick (Event "a")

                  else
                    onClick NoOp
                ]
                []
            ]


event22 : Model -> Html Msg
event22 model =
    wrap model InsertBeforeTarget "event22" <|
        div []
            [ span
                [ class "target"
                , class "button"
                , if beforeOrAfter "event22" model == "before" then
                    onClick NoOp

                  else
                    onClick (Event "a")
                ]
                []
            ]


event23 : Model -> Html Msg
event23 model =
    wrap model InsertBeforeTarget "event23" <|
        div []
            [ Html.map Nest <|
                span
                    [ class "target"
                    , class "button"
                    , onClick (Event (beforeOrAfter "event23" model))
                    ]
                    []
            ]


event24 : Model -> Html Msg
event24 model =
    wrap model InsertBeforeTarget "event24" <|
        div []
            [ Html.map Nest <|
                span
                    [ class "target"
                    , class "button"
                    , if beforeOrAfter "event24" model == "before" then
                        onClick (Event "a")

                      else
                        onClick (Nest (Event "b"))
                    ]
                    []
            ]


event25 : Model -> Html Msg
event25 model =
    wrap model InsertBeforeTarget "event25" <|
        div []
            [ Html.map Nest <|
                span
                    [ class "target"
                    , class "button"
                    , if beforeOrAfter "event25" model == "before" then
                        onClick (Nest (Event "a"))

                      else
                        onClick (Event "b")
                    ]
                    []
            ]


event26 : Model -> Html Msg
event26 model =
    wrap model InsertBeforeTarget "event26" <|
        div []
            [ Html.map Nest <|
                Html.map Nest <|
                    span
                        [ class "target"
                        , class "button"
                        , onClick (Event (count "event26" model))
                        ]
                        []
            ]


event27 : Model -> Html Msg
event27 model =
    wrap model InsertBeforeTarget "event27" <|
        div []
            [ (if beforeOrAfter "event27" model == "before" then
                identity

               else
                Html.map Nest
              )
              <|
                Html.map Nest <|
                    span
                        [ class "target"
                        , class "button"
                        , onClick (Event (count "event27" model))
                        ]
                        []
            ]


event28 : Model -> Html Msg
event28 model =
    wrap model InsertBeforeTarget "event28" <|
        div []
            [ (if beforeOrAfter "event28" model == "before" then
                Html.map Nest

               else
                identity
              )
              <|
                Html.map Nest <|
                    span
                        [ class "target"
                        , class "button"
                        , onClick (Event (count "event28" model))
                        ]
                        []
            ]



-- KEYED


keyed1 : Model -> Html Msg
keyed1 model =
    wrap model InsertBeforeTarget "keyed1" <|
        Html.Keyed.node "div"
            []
            [ ( "0"
              , div
                    [ class "target"
                    , class ("e" ++ count "keyed1" model)
                    ]
                    []
              )
            ]


keyed2 : Model -> Html Msg
keyed2 model =
    wrap model InsertBeforeTarget "keyed2" <|
        Html.Keyed.node "div"
            [ class ("e" ++ count "keyed2" model) ]
            [ ( count "keyed2" model
              , div
                    [ class "target"
                    ]
                    []
              )
            ]


keyed3 : Model -> Html Msg
keyed3 model =
    wrap model InsertBeforeTarget "keyed3" <|
        Html.Keyed.node "div"
            []
            [ ( count "keyed3" model
              , div
                    [ class "target"
                    , class ("e" ++ count "keyed3" model)
                    ]
                    [ text ("e" ++ count "keyed3" model) ]
              )
            ]


keyed4 : Model -> Html Msg
keyed4 model =
    wrap model InsertBeforeTarget "keyed4" <|
        div []
            [ Html.Keyed.node "div"
                [ class "target"
                , class ("e" ++ count "keyed4" model)
                ]
                []
            ]


keyed5 : Model -> Html Msg
keyed5 model =
    wrap model WrapTarget "keyed5" <|
        div []
            [ Html.Keyed.node "div"
                [ class "target"
                , class ("e" ++ count "keyed5" model)
                ]
                []
            ]


keyed6 : Model -> Html Msg
keyed6 model =
    wrap model (UpdateAttribute "title") "keyed6" <|
        Html.Keyed.node "div"
            []
            [ ( "1"
              , div
                    [ class "target"
                    , class ("e" ++ count "keyed6" model)
                    ]
                    [ text (count "keyed6" model) ]
              )
            ]


keyed7 : Model -> Html Msg
keyed7 model =
    wrap model (UpdateAttribute "title") "keyed7" <|
        Html.Keyed.node "div"
            [ class ("e" ++ count "keyed7" model) ]
            [ ( "1"
              , div
                    [ class "target"
                    ]
                    []
              )
            ]


keyed8 : Model -> Html Msg
keyed8 model =
    wrap model (UpdateAttribute "title") "keyed8" <|
        Html.Keyed.node "div"
            [ class ("e" ++ count "keyed8" model) ]
            [ ( count "keyed8" model
              , div
                    [ class "target"
                    ]
                    [ text (count "keyed8" model) ]
              )
            ]


keyed9 : Model -> Html Msg
keyed9 model =
    wrap model (UpdateAttribute "title") "keyed9" <|
        Html.Keyed.node "div"
            []
            (if beforeOrAfter "keyed9" model == "before" then
                [ ( "1"
                  , div
                        [ class "target"
                        ]
                        []
                  )
                ]

             else
                []
            )


keyed10 : Model -> Html Msg
keyed10 model =
    wrap model (UpdateAttribute "title") "keyed10" <|
        Html.Keyed.node "div"
            []
            (if beforeOrAfter "keyed10" model == "before" then
                [ ( "1"
                  , div
                        [ class "target"
                        , class "e1"
                        ]
                        []
                  )
                , ( "2"
                  , div
                        [ class "e2"
                        ]
                        []
                  )
                ]

             else
                [ ( "2"
                  , div
                        [ class "e2"
                        ]
                        []
                  )
                , ( "1"
                  , div
                        [ class "target"
                        , class "e1"
                        ]
                        []
                  )
                ]
            )


keyed11 : Model -> Html Msg
keyed11 model =
    wrap model (UpdateAttribute "title") "keyed11" <|
        Html.Keyed.node "div"
            []
            (if beforeOrAfter "keyed11" model == "before" then
                [ ( "1"
                  , div
                        [ class "e1"
                        ]
                        []
                  )
                , ( "2"
                  , div
                        [ class "target"
                        , class "e2"
                        ]
                        []
                  )
                ]

             else
                [ ( "2"
                  , div
                        [ class "target"
                        , class "e2"
                        ]
                        []
                  )
                , ( "1"
                  , div
                        [ class "e1"
                        ]
                        []
                  )
                ]
            )


keyed12 : Model -> Html Msg
keyed12 model =
    wrap model InsertBeforeTarget "keyed12" <|
        Html.Keyed.node "div"
            []
            (if beforeOrAfter "keyed12" model == "before" then
                [ ( "1"
                  , div
                        [ class "target"
                        , class "e1"
                        ]
                        []
                  )
                , ( "2"
                  , div
                        [ class "e2"
                        ]
                        []
                  )
                ]

             else
                [ ( "2"
                  , div
                        [ class "e2"
                        ]
                        []
                  )
                , ( "1"
                  , div
                        [ class "target"
                        , class "e1"
                        ]
                        []
                  )
                ]
            )


keyed13 : Model -> Html Msg
keyed13 model =
    wrap model InsertBeforeTarget "keyed13" <|
        Html.Keyed.node "div"
            []
            (if beforeOrAfter "keyed13" model == "before" then
                [ ( "1"
                  , div
                        [ class "e1"
                        ]
                        []
                  )
                , ( "2"
                  , div
                        [ class "target"
                        , class "e2"
                        ]
                        []
                  )
                ]

             else
                [ ( "2"
                  , div
                        [ class "target"
                        , class "e2"
                        ]
                        []
                  )
                , ( "1"
                  , div
                        [ class "e1"
                        ]
                        []
                  )
                ]
            )


keyed14 : Model -> Html Msg
keyed14 model =
    wrap model InsertBeforeTarget "keyed14" <|
        Html.Keyed.node "div"
            []
            (if beforeOrAfter "keyed14" model == "before" then
                [ ( "1"
                  , div
                        [ class "target"
                        , class "e1"
                        ]
                        []
                  )
                ]

             else
                [ ( "1"
                  , div
                        [ class "target"
                        , class "e1"
                        ]
                        []
                  )
                , ( "2"
                  , div
                        [ class "e2"
                        ]
                        []
                  )
                ]
            )


keyed15 : Model -> Html Msg
keyed15 model =
    wrap model InsertBeforeTarget "keyed15" <|
        Html.Keyed.node "div"
            []
            (if beforeOrAfter "keyed15" model == "before" then
                [ ( "1"
                  , div
                        [ class "target"
                        , class "e1"
                        ]
                        []
                  )
                ]

             else
                [ ( "2"
                  , div
                        [ class "e2"
                        ]
                        []
                  )
                , ( "1"
                  , div
                        [ class "target"
                        , class "e1"
                        ]
                        []
                  )
                ]
            )


keyed16 : Model -> Html Msg
keyed16 model =
    wrap model InsertBeforeTarget "keyed16" <|
        Html.Keyed.node "div"
            []
            (if beforeOrAfter "keyed16" model == "before" then
                [ ( "1"
                  , div
                        [ class "target"
                        ]
                        []
                  )
                ]

             else
                []
            )


keyed17 : Model -> Html Msg
keyed17 model =
    wrap model AppendToTarget "keyed17" <|
        Html.Keyed.node "div"
            [ class "target" ]
            [ ( "1", text (count "keyed17" model) ) ]


keyed18 : Model -> Html Msg
keyed18 model =
    wrap model AppendToTarget "keyed18" <|
        Html.Keyed.node "div"
            [ class "target" ]
            [ ( count "keyed18" model, text (count "keyed18" model) ) ]


keyed19 : Model -> Html Msg
keyed19 model =
    wrap model AppendToTarget "keyed19" <|
        Html.Keyed.node "div"
            [ class "target" ]
            (if beforeOrAfter "keyed19" model == "before" then
                [ ( "1", text "" ) ]

             else
                []
            )


keyed20 : Model -> Html Msg
keyed20 model =
    wrap model AppendToTarget "keyed20" <|
        Html.Keyed.node "div"
            [ class "target" ]
            (if beforeOrAfter "keyed20" model == "before" then
                []

             else
                [ ( "1", text "" ) ]
            )


keyed21 : Model -> Html Msg
keyed21 model =
    wrap model AppendToTarget "keyed21" <|
        Html.Keyed.node "div"
            [ class "target" ]
            [ ( "1", div [ class ("e" ++ count "keyed21" model) ] [ text (count "keyed21" model) ] ) ]


keyed22 : Model -> Html Msg
keyed22 model =
    wrap model AppendToTarget "keyed22" <|
        Html.Keyed.node "div"
            [ class "target" ]
            [ ( count "keyed22" model, div [ class ("e" ++ count "keyed22" model) ] [ text (count "keyed22" model) ] ) ]


keyed23 : Model -> Html Msg
keyed23 model =
    wrap model AppendToTarget "keyed23" <|
        Html.Keyed.node "div"
            [ class "target" ]
            (if beforeOrAfter "keyed23" model == "before" then
                [ ( "1", div [ class "e1" ] [ text "" ] ) ]

             else
                []
            )


keyed24 : Model -> Html Msg
keyed24 model =
    wrap model AppendToTarget "keyed24" <|
        Html.Keyed.node "div"
            [ class "target" ]
            (if beforeOrAfter "keyed24" model == "before" then
                []

             else
                [ ( "1", div [ class "e1" ] [ text "" ] ) ]
            )


keyed25 : Model -> Html Msg
keyed25 model =
    wrap model AppendToTarget "keyed25" <|
        Html.Keyed.node
            (if beforeOrAfter "keyed25" model == "before" then
                "div"

             else
                "p"
            )
            [ class "target", class ("e" ++ count "keyed25" model) ]
            []


keyed26 : Model -> Html Msg
keyed26 model =
    wrap model AppendToTarget "keyed26" <|
        if beforeOrAfter "keyed26" model == "before" then
            Html.Keyed.node "div" [ class "target", class "e1" ] [ ( "a", text "" ), ( "b", div [] [] ) ]

        else
            div [ class "target", class "e2" ] []


keyed27 : Model -> Html Msg
keyed27 model =
    wrap model AppendToTarget "keyed27" <|
        if beforeOrAfter "keyed27" model == "before" then
            div [ class "target", class "e1" ] []

        else
            Html.Keyed.node "div" [ class "target", class "e2" ] []


keyed28 : Model -> Html Msg
keyed28 model =
    wrap model InsertBeforeTarget "keyed28" <|
        div []
            [ Html.Keyed.node
                (if beforeOrAfter "keyed28" model == "before" then
                    "div"

                 else
                    "p"
                )
                [ class "target", class ("e" ++ count "keyed28" model) ]
                []
            ]


keyed29 : Model -> Html Msg
keyed29 model =
    wrap model AppendToTarget "keyed29" <|
        div []
            [ if beforeOrAfter "keyed29" model == "before" then
                Html.Keyed.node "div" [ class "target", class "e1" ] [ ( "a", text "" ), ( "b", div [] [] ) ]

              else
                div [ class "target", class "e2" ] []
            ]


keyed30 : Model -> Html Msg
keyed30 model =
    wrap model AppendToTarget "keyed30" <|
        div []
            [ if beforeOrAfter "keyed30" model == "before" then
                div [ class "target", class "e1" ] []

              else
                Html.Keyed.node "div" [ class "target", class "e2" ] []
            ]



-- LAZY


viewText1 : String -> Html msg
viewText1 s =
    text s


viewDiv1 : String -> Html msg
viewDiv1 s =
    div [] [ text s ]


viewTarget1 : String -> Html msg
viewTarget1 s =
    div [ class "target" ] [ text s ]


lazy1 : Model -> Html Msg
lazy1 model =
    wrap model InsertBeforeTarget "lazy1" <|
        div []
            [ div [ class "target" ] [ lazy viewText1 (beforeOrAfter "lazy1" model) ]
            ]


lazy2 : Model -> Html Msg
lazy2 model =
    wrap model RemoveTarget "lazy2" <|
        div []
            [ div [ class "target" ] [ lazy viewText1 (beforeOrAfter "lazy2" model) ]
            ]


lazy3 : Model -> Html Msg
lazy3 model =
    wrap model WrapTarget "lazy3" <|
        div []
            [ div [ class "target" ] [ lazy viewText1 (beforeOrAfter "lazy3" model) ]
            ]


lazy4 : Model -> Html Msg
lazy4 model =
    wrap model AppendToTarget "lazy4" <|
        div [ class "target" ]
            [ lazy viewText1 (beforeOrAfter "lazy4" model)
            ]


lazy5 : Model -> Html Msg
lazy5 model =
    wrap model InsertBeforeTarget "lazy5" <|
        div []
            [ div [ class "target" ] [ lazy viewDiv1 (beforeOrAfter "lazy5" model) ]
            ]


lazy6 : Model -> Html Msg
lazy6 model =
    wrap model RemoveTarget "lazy6" <|
        div []
            [ div [ class "target" ] [ lazy viewDiv1 (beforeOrAfter "lazy6" model) ]
            ]


lazy7 : Model -> Html Msg
lazy7 model =
    wrap model WrapTarget "lazy7" <|
        div []
            [ div [ class "target" ] [ lazy viewDiv1 (beforeOrAfter "lazy7" model) ]
            ]


lazy8 : Model -> Html Msg
lazy8 model =
    wrap model AppendToTarget "lazy8" <|
        div [ class "target" ]
            [ lazy viewDiv1 (beforeOrAfter "lazy8" model)
            ]


lazy9 : Model -> Html Msg
lazy9 model =
    wrap model InsertBeforeTarget "lazy9" <|
        div []
            [ div [ class "target" ] [ lazy text (beforeOrAfter "lazy9" model) ]
            ]


lazy10 : Model -> Html Msg
lazy10 model =
    wrap model RemoveTarget "lazy10" <|
        div []
            [ div [ class "target" ] [ lazy text (beforeOrAfter "lazy10" model) ]
            ]


lazy11 : Model -> Html Msg
lazy11 model =
    wrap model WrapTarget "lazy11" <|
        div []
            [ div [ class "target" ] [ lazy text (beforeOrAfter "lazy11" model) ]
            ]


lazy12 : Model -> Html Msg
lazy12 model =
    wrap model AppendToTarget "lazy12" <|
        div [ class "target" ]
            [ lazy text (beforeOrAfter "lazy12" model)
            ]


lazy13 : Model -> Html Msg
lazy13 model =
    wrap model InsertBeforeTarget "lazy13" <|
        div []
            [ div [ class "target" ] [ lazy (\s -> text s) (beforeOrAfter "lazy13" model) ]
            ]


lazy14 : Model -> Html Msg
lazy14 model =
    wrap model RemoveTarget "lazy14" <|
        div []
            [ div [ class "target" ] [ lazy (\s -> text s) (beforeOrAfter "lazy14" model) ]
            ]


lazy15 : Model -> Html Msg
lazy15 model =
    wrap model WrapTarget "lazy15" <|
        div []
            [ div [ class "target" ] [ lazy (\s -> text s) (beforeOrAfter "lazy15" model) ]
            ]


lazy16 : Model -> Html Msg
lazy16 model =
    wrap model AppendToTarget "lazy16" <|
        div [ class "target" ]
            [ lazy (\s -> text s) (beforeOrAfter "lazy16" model)
            ]


lazy17 : Model -> Html Msg
lazy17 model =
    wrap model InsertBeforeTarget "lazy17" <|
        div []
            [ lazy viewTarget1 (beforeOrAfter "lazy17" model)
            ]


lazy18 : Model -> Html Msg
lazy18 model =
    wrap model RemoveTarget "lazy18" <|
        div []
            [ lazy viewTarget1 (beforeOrAfter "lazy18" model)
            ]


lazy19 : Model -> Html Msg
lazy19 model =
    wrap model WrapTarget "lazy19" <|
        div []
            [ lazy viewTarget1 (beforeOrAfter "lazy19" model)
            ]


lazy20 : Model -> Html Msg
lazy20 model =
    wrap model AppendToTarget "lazy20" <|
        lazy viewTarget1 (beforeOrAfter "lazy20" model)



-- ANCHORS


route1 : Model -> Html Msg
route1 model =
    wrap model (\_ -> NoOp) "route1" <|
        div []
            [ a
                [ class "target"
                , class ("e" ++ count "route1" model)
                , href "/InsertBeforeTarget/route1"
                ]
                [ text (count "route1" model) ]
            ]


route2 : Model -> Html Msg
route2 model =
    wrap model (\_ -> NoOp) "route2" <|
        div []
            [ div [ class ("e" ++ count "route2" model) ] []
            , a
                [ class "target"
                , href "/InsertBeforeTarget/route2"
                ]
                [ text (count "route2" model) ]
            ]


route3 : Model -> Html Msg
route3 model =
    wrap model (\_ -> NoOp) "route3" <|
        div []
            [ a
                [ class "target"
                , href "/InsertBeforeTarget/route3"
                ]
                [ text (count "route3" model) ]
            , div [ class ("e" ++ count "route3" model) ] []
            ]


route4 : Model -> Html Msg
route4 model =
    wrap model (\_ -> NoOp) "route4" <|
        div [ class ("e" ++ count "route4" model) ]
            [ a
                [ class "target"
                , href "/InsertBeforeTarget/route4"
                ]
                [ text "a" ]
            ]


route5 : Model -> Html Msg
route5 model =
    wrap model (\_ -> NoOp) "route5" <|
        div []
            [ a
                [ class "target"
                , class ("e" ++ count "route5" model)
                , href "/RemoveTarget/route5"
                ]
                [ text (count "route5" model) ]
            ]


route6 : Model -> Html Msg
route6 model =
    wrap model (\_ -> NoOp) "route6" <|
        div []
            [ a
                [ class "target"
                , class ("e" ++ count "route6" model)
                , href "/WrapTarget/route6"
                ]
                [ text (count "route6" model) ]
            ]


route7 : Model -> Html Msg
route7 model =
    wrap model (\_ -> NoOp) "route7" <|
        a
            [ class "target"
            , href "/AppendToTarget/route7"
            ]
            [ div [ class ("e" ++ count "route7" model) ] [ text (count "route7" model) ] ]


route8 : Model -> Html Msg
route8 model =
    wrap model (\_ -> NoOp) "route8" <|
        a
            [ class "target"
            , href "/AppendToTarget/route8"
            ]
            (if beforeOrAfter "route8" model == "before" then
                [ text "a" ]

             else
                [ text "a"
                , div [ class ("e" ++ count "route8" model) ] []
                ]
            )


route9 : Model -> Html Msg
route9 model =
    wrap model (\_ -> NoOp) "route9" <|
        a
            [ class "target"
            , class ("e" ++ count "route9" model)
            , href "/AppendToTarget/route9"
            ]
            (if beforeOrAfter "route9" model == "route9" then
                [ text "a"
                , div [] []
                ]

             else
                [ text "a" ]
            )


route10 : Model -> Html Msg
route10 model =
    wrap model (\_ -> NoOp) "route10" <|
        a
            [ class "target"
            , href "/InsertIntoBody/route10"
            , class ("e" ++ count "route10" model)
            ]
            [ text "a" ]



-- EDGE


edge1 : Model -> Html Msg
edge1 model =
    wrap model AppendToTarget "edge1" <|
        div
            [ class "target"
            ]
            [ node "script" [] [ text (count "edge1" model) ]
            , a [ href "javascript:void(0)" ] [ text (count "edge1" model) ]
            , div [ attribute "onclick" "" ] []
            , nodeNS "http://www.w3.org/2000/svg"
                "path"
                [ attributeNS "http://www.w3.org/1999/xlink" "xlink:href" (count "edge1" model)
                ]
                []
            , nodeNS "http://www.w3.org/2000/svg"
                "path"
                (if beforeOrAfter "edge1" model == "before" then
                    [ attributeNS "http://www.w3.org/1999/xlink" "xlink:href" (count "edge1" model) ]

                 else
                    []
                )
                []
            , div
                [ class "e1"
                , on "click" (D.succeed (Event "1"))
                ]
                [ text "1" ]
            , div
                [ class "e2"
                , preventDefaultOn "click"
                    (D.succeed ( Event "2", countAsInt "edge1" model // 2 == 0 ))
                ]
                [ text "2" ]
            , div
                [ class "e3"
                , stopPropagationOn "click"
                    (D.succeed ( Event "3", countAsInt "edge1" model // 2 == 1 ))
                ]
                [ text "3" ]
            , div
                [ class "e4"
                , custom "click"
                    (D.succeed
                        { stopPropagation = countAsInt "edge1" model // 2 == 0
                        , preventDefault = countAsInt "edge1" model // 2 == 1
                        , message = Event "4"
                        }
                    )
                ]
                [ text "4" ]
            , div [ class "e5", on "click" (D.fail "") ] [ text "5" ]
            , div [ class "e6", preventDefaultOn "click" (D.fail "") ] [ text "6" ]
            , div [ class "e7", stopPropagationOn "click" (D.fail "") ] [ text "7" ]
            , div [ class "e8", custom "click" (D.fail "") ] [ text "8" ]
            , div [ attribute "class" (count "edge1" model) ] []
            , div
                [ if beforeOrAfter "edge1" model == "before" then
                    attribute "class" (count "edge1" model)

                  else
                    class (count "edge1" model)
                ]
                []
            , div
                [ if beforeOrAfter "edge1" model == "before" then
                    class (count "edge1" model)

                  else
                    attribute "class" (count "edge1" model)
                ]
                []
            ]



-- BOUNDARY


boundary1 : Model -> Html Msg
boundary1 model =
    wrap model (InsertIntoBody 1 0) "boundary1" <|
        text (count "boundary1" model)


boundary2 : Model -> Html Msg
boundary2 model =
    wrap model (InsertIntoBody 1 0) "boundary2" <|
        text (count "boundary2" model)


boundary3 : Model -> Html Msg
boundary3 model =
    wrap model (InsertIntoBody 1 0) "boundary3" <|
        text (count "boundary3" model)


boundary4 : Model -> Html Msg
boundary4 model =
    wrap model (InsertIntoBody 1 0) "boundary4" <|
        text (count "boundary4" model)


boundary5 : Model -> Html Msg
boundary5 model =
    wrap model (InsertIntoBody 1 0) "boundary5" <|
        text (count "boundary5" model)


boundary6 : Model -> Html Msg
boundary6 model =
    wrap model (InsertIntoBody 1 0) "boundary6" <|
        text (count "boundary6" model)


boundary7 : Model -> Html Msg
boundary7 model =
    wrap model (InsertIntoBody 0 1) "boundary7" <|
        text (count "boundary7" model)


boundary8 : Model -> Html Msg
boundary8 model =
    wrap model (InsertIntoBody 0 1) "boundary8" <|
        text (count "boundary8" model)


boundary9 : Model -> Html Msg
boundary9 model =
    wrap model (InsertIntoBody 0 1) "boundary9" <|
        text (count "boundary9" model)


boundary10 : Model -> Html Msg
boundary10 model =
    wrap model (InsertIntoBody 0 1) "boundary10" <|
        text (count "boundary10" model)


boundary11 : Model -> Html Msg
boundary11 model =
    wrap model (InsertIntoBody 0 1) "boundary11" <|
        text (count "boundary11" model)


boundary12 : Model -> Html Msg
boundary12 model =
    wrap model (InsertIntoBody 0 1) "boundary12" <|
        text (count "boundary12" model)

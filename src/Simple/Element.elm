module Simple.Element exposing (main)

import Browser
import Simple.Common exposing (Model, Msg, init, subscriptions, update, viewInner)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = viewInner
        }

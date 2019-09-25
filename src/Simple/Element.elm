module Simple.Element exposing (main)

import Browser
import Simple.Common exposing (Model, Msg, init, subscriptions, update, view)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

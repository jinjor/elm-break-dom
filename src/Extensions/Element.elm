module Extensions.Element exposing (main)

import Browser
import Extensions.Common exposing (Model, Msg, init, subscriptions, update, view)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

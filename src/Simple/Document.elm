module Simple.Document exposing (main)

import Browser
import Simple.Common exposing (Model, Msg, init, subscriptions, update, view)


main : Program () Model Msg
main =
    Browser.document
        { init = \flags -> init flags
        , update = update
        , subscriptions = subscriptions
        , view =
            \model ->
                { title = ""
                , body = [ view model ]
                }
        }

module Element exposing (main)

import Browser
import Extensions


main : Program () Extensions.Model Extensions.Msg
main =
    Browser.element
        { init = Extensions.init
        , update = Extensions.update
        , subscriptions = Extensions.subscriptions
        , view = Extensions.view
        }

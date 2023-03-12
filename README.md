# NetworkXI

### Exquisite networking package for iOS (version >= 13.0)

<br>

## List of features
- NetworkXI utilizes fundamental `URLSession` under the hood
- NetworkXI exclusively takes advantage of *Async/await* approach for request making
- All interactions with NetworkXI are based on protocols, so you can make your own implementations of
`NetworkSessionInterface`, `NetworkService`
- NetworkXI provides logger that prints beautifully crafted request/response events into *Xcode* console
- NetworkXI provides the opportunity to renew session by updating authorization
- NetworkXI supports SSL certificate pinning along with default challenge
- NetworkXI supports easily implemented response mocking
- NetworkXI supports separate implementation (`WebSocketSessionInterface`, `WebSocketService`) of web-socket message
exchange

<br>

## Example of use

#### Creating URL list
```Swift
import NetworkXI

struct HttpbinOrgURL: RequestURLExtensible {

    let path: String
    var host: String { "httpbin.org" }
}

extension HttpbinOrgURL {

    static let uuid = Self("/uuid")
}

```

#### Describing request
```Swift
import NetworkXI

class UUIDRequest: NetworkRequest {

    var url: RequestURL { HttpbinOrgURL.uuid }
    var method: RequestMethod { .GET }
    var encoding: RequestContentEncoding { .url }
}

```

#### Making the request
```Swift
import NetworkXI

// Create session interface and use it across the app
let sessionAdapter = NetworkSessionAdapter()
sessionAdapter.defaultSSLChallengeEnabled = true

// Work with a new instance of network service
let worker = NetworkWorker(sessionInterface: sessionAdapter)

let request = UUIDRequest()
let response = await worker.make(request)

if response.success,
   let body = response.jsonBody,
   let uuidString = body["uuid"] as? String {
    print("UUID: " + uuidString)
}
```

<br>

## License

**NetworkXI** is released under the **MIT** license

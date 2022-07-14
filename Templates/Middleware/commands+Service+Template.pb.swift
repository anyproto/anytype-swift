        private static func invoke(request: Request, on queue: DispatchQueue?) -> Future<Response, Error> {
            .init { promise in
                if let queue = queue {
                    queue.async {
                        promise(self.result(request))
                    }
                }
                else {
                    promise(self.result(request))
                }
            }
        }
        private static func result(_ request: Request) -> Result<Response, Error> {
            guard let result = self.invoke(request) else {
                // get first Not Null (not equal 0) case.
                return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
            }
            // get first zero case.
            if result.error.code != .null {
                let domain = Anytype_Middleware_Error.domain
                let code = result.error.code.rawValue
                let description = result.error.description_p
                return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
            }
            else {
                return .success(result)
            }
        }
        private static func invoke(_ request: Request) -> Response? {
            Invocation.invoke(try? request.serializedData()).flatMap {
                try? Response(serializedData: $0)
            }
        }

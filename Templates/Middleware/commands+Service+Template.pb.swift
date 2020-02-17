        private static func result(_ request: Request) -> Result<Response, Error> {
            guard let result = self.invoke(request) else {
                // get first Not Null (not equal 0) case.
                return .failure(Response.Error(code: .unknownError, description_p: "Unknown error during parsing"))
            }
            // get first zero case.
            if result.error.code != .null {
                return .failure(result.error)
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

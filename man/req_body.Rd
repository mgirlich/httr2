% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/req-body.R
\name{req_body}
\alias{req_body_raw}
\alias{req_body_file}
\alias{req_body_json}
\alias{req_body_form}
\alias{req_body_multipart}
\title{Send data in request body}
\usage{
req_body_raw(req, body, type = NULL)

req_body_file(req, path, type = NULL)

req_body_json(req, data, auto_unbox = TRUE, digits = 22, null = "null", ...)

req_body_form(.req, ...)

req_body_multipart(.req, ...)
}
\arguments{
\item{req, .req}{A \link{request}.}

\item{body}{A literal string or raw vector to send as body.}

\item{type}{Content type. For \code{req_body_file()}, the default
will will attempt to guess from the extension of \code{path}.}

\item{path}{Path to file to upload.}

\item{data}{Data to include in body.}

\item{auto_unbox}{Should length-1 vectors be automatically "unboxed" to
JSON scalars?}

\item{digits}{How many digits of precision should numbers use in JSON?}

\item{null}{Should \code{NULL} be translated to JSON's null (\code{"null"})
or an empty list (\code{"list"}).}

\item{...}{Name-data pairs used send data in the body. For
\code{req_body_form()}, the values must be strings (or things easily
coerced to string); for \code{req_body_multipart()} the values must be
strings or objects produced by \code{\link[curl:multipart]{curl::form_file()}}/\code{\link[curl:multipart]{curl::form_data()}}.

For \code{req_body_json()}, additional arguments passed on to
\code{\link[jsonlite:fromJSON]{jsonlite::toJSON()}}.}
}
\value{
A modified HTTP \link{request}.
}
\description{
\itemize{
\item \code{req_body_file()} sends a local file.
\item \code{req_body_raw()} sends a string or raw vector.
\item \code{req_body_json()} sends JSON encoded data.
\item \code{req_body_form()} sends form encoded data.
\item \code{req_body_multipart()} creates a multi-part body.
}

Adding a body to a request will automatically switch the method to POST.
}
\examples{
req <- request("http://httpbin.org/post")

# Most APIs expect small amounts of data in either form or json encoded:
req \%>\%
  req_body_form(x = "A simple text string") \%>\%
  req_dry_run()

req \%>\%
  req_body_json(list(x = "A simple text string")) \%>\%
  req_dry_run()

# For total control over the body, send a string or raw vector
req \%>\%
  req_body_raw("A simple text string") \%>\%
  req_dry_run()

# There are two main ways that APIs expect entire files
path <- tempfile()
writeLines(letters[1:6], path)

# You can send a single file as the body:
req \%>\%
  req_body_file(path) \%>\%
  req_dry_run()

# You can send multiple files, or a mix of files and data
# with multipart encoding
req \%>\%
  req_body_multipart(a = curl::form_file(path), b = "some data") \%>\%
  req_dry_run()
}

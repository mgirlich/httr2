% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/req-retries.R
\name{req_retry}
\alias{req_retry}
\title{Control when a request will retry, and how long it will wait between tries}
\usage{
req_retry(
  req,
  max_tries = NULL,
  max_seconds = NULL,
  is_transient = NULL,
  backoff = NULL,
  after = NULL
)
}
\arguments{
\item{req}{A \link{request}.}

\item{max_tries, max_seconds}{Cap the maximum number of attempts with
\code{max_tries} or the total elapsed time from the first request with
\code{max_seconds}. If neither option is supplied (the default), \code{\link[=req_perform]{req_perform()}}
will not retry.}

\item{is_transient}{A predicate function that takes a single argument
(the response) and returns \code{TRUE} or \code{FALSE} specifying whether or not
the response represents a transient error.}

\item{backoff}{A function that takes a single argument (the number of failed
attempts so far) and returns the number of seconds to wait.}

\item{after}{A function that takes a single argument (the response) and
returns either a number of seconds to wait or \code{NULL}, which indicates
that a precise wait time is not available that the \code{backoff} strategy
should be used instead..}
}
\value{
A modified HTTP \link{request}.
}
\description{
\code{req_retry()} alters \code{\link[=req_perform]{req_perform()}} so that it will automatically retry
in the case of failure. To activate it, you must specify either the total
number of requests to make with \code{max_tries} or the total amount of time
to spend with \code{max_seconds}. Then \code{req_perform()} will retry if:
\itemize{
\item The either the HTTP request or HTTP response doesn't complete successfully
leading to an error from curl, the lower-level library that httr uses to
perform HTTP request. This occurs, for example, if your wifi is down.
\item The error is "transient", i.e. it's an HTTP error that can be resolved
by waiting. By default, 429 and 503 statuses are treated as transient,
but if the API you are wrapping has other transient status codes (or
conveys transient-ness with some other property of the response), you can
override the default with \code{is_transient}.
}

It's a bad idea to immediately retry a request, so \code{req_perform()} will
wait a little before trying again:
\itemize{
\item If the response contains the \code{Retry-After} header, httr2 will wait the
amount of time it specifies. If the API you are wrapping conveys this
information with a different header (or other property of the response)
you can override the default behaviour with \code{retry_after}.
\item Otherwise, httr2 will use "truncated exponential backoff with full
jitter", i.e. it will wait a random amount of time between one second and
\code{2 ^ tries} seconds, capped to at most 60 seconds. In other words, it
waits \code{runif(1, 1, 2)} seconds after the first failure, \code{runif(1, 1, 4)}
after the second, \code{runif(1, 1, 8)} after the third, and so on. If you'd
prefer a different strategy, you can override the default with \code{backoff}.
}
}
\examples{
# google APIs assume that a 500 is also a transient error
request("http://google.com") \%>\%
  req_retry(is_transient = ~ resp_status(.x) \%in\% c(429, 500, 503))

# use a constant 10s delay after every failure
request("http://example.com") \%>\%
  req_retry(backoff = ~ 10)

# When rate-limited, GitHub's API returns a 403 with
# `X-RateLimit-Remaining: 0` and an Unix time stored in the
# `X-RateLimit-Reset` header. This takes a bit more work to handle:
github_is_transient <- function(resp) {
  resp_status(resp) == 403 &&
    identical(resp_header(resp, "X-RateLimit-Remaining"), "0")
}
github_after <- function(resp) {
  time <- as.numeric(resp_header(resp, "X-RateLimit-Reset"))
  time - unclass(Sys.time())
}
request("http://api.github.com") \%>\%
  req_retry(
    is_transient = github_is_transient,
    after = github_after
  )
}
\seealso{
\code{\link[=req_throttle]{req_throttle()}} if the API has a rate-limit but doesn't expose
the limits in the response.
}

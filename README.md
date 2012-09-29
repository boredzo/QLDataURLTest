# QLDataURL and NSData data: URI category

This repository contains two things:

## A category on NSData for the creation of data: URIs

This category adds one public method to NSData instances to make it easy to create data: URIs. You pass in a MIME type (required by the data: URI spec) describing the type of data; it returns an NSURL object containing the URI.

Warning: The returned URI may be long (proportionally to the input data). Be careful where you output it, so as not to bury the user in seemingly garbage text.

## A test app testing the use of data: URIs with Quick Look

The Quick Look APIs require you to specify items to preview or generate thumbnails for as file URLs. I wondered whether you could pass bare data by wrapping it in a data: URI.

The answer is no. The app proves this by experiment.

Aside from demonstrating the use of the various Quick Look APIs, there is nothing else to do with the app. I recommend ignoring it.

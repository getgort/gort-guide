Output Format Templates
=======================

Output format templating is a powerful feature that allows you to
control the look and feel (and, to some degree, content) of any
information sent to users. Both Gort system messages and command output
support templates for customization (within the constraints imposed by a
given chat provider).

The four template types
-----------------------

The are four template types:

-  *Command templates*, which are used to format the outputs from
   successfully executed commands.
-  *Command error templates*, which are used to format the error
   messages produced by commands that exit with a non-zero status.
-  *Message templates*, which are used to format standard informative
   (non-error) messages from the Gort system (not commands).
-  *Message error templates*, which are used to format error messages
   from the Gort system (not commands).

Each of these have default values built into Gort, but each may be
customized via the ``templates`` block of the `Gort
configuration <configuration.html>`__. Furthermore, the *command* and
*command error* templates may be further customized per bundle, or even
per command.

Template Basic Format
---------------------

Gort templates use Go's `template
syntax <https://pkg.go.dev/text/template>`__ to format output in a
chat-agnostic way.

For example, a very simple *command template* might look something like
the following:

::

    {{ text | monospace true }}{{ .Response.Out }}{{ endtext }}

This template emits the command's response (``.Response.Out``) as
monospaced text, which may look something like the following:

.. figure:: ../images/command-mono.png
   :alt: Monospaced command output

   Monospaced command output

A slightly more complicated template, this one a *command error
template* (actually the default), is shown below.

::

    {{ header | color "#FF0000" | title .Response.Title }}
    {{ text }}The pipeline failed planning the invocation:{{ endtext }}
    {{ text | monospace true }}{{ .Request.Bundle.Name }}:{{ .Request.Command.Name }} {{ .Request.Parameters }}{{ endtext }}
    {{ text }}The specific error was:{{ endtext }}
    {{ text | monospace true }}{{ .Response.Out }}{{ endtext }}

This one includes a header with a color and title, as well as some
alternating monospaced and standard text. In this case, this will format
a command error something like the following:

.. image:: ../images/command-formatted.png
   :alt: Pretty command error message

Sure that's nice and all, but what's all this ``.Response`` stuff?
That's part of what's called the "response envelope", a data structure
that's accessible from any template, which makes available all of the
data and metadata around one command request, execution, and response.
The response envelope is discussed in detail in :doc:`templates-response-envelope`.

The available template tags and functions are also fully presented in :doc:`templates-functions`.

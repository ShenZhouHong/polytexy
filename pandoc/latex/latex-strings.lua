-- Template files for custom pandoc LaTeX writer
-- loaded by writer.lua

SingleQuoteTemplate = "\\enquote*{%s}"

DoubleQuoteTemplate = "\\enquote{%s}"


BlockQuoteTemplate = [[
\begin{displayquote}
%s
\end{displayquote}
]]

VerbatimTemplate = [[
\begin{verbatim}
%s
\end{verbatim}
]]

MintedTemplate = [[
\begin{listing}[h]
\begin{minted}[baselinestretch=1.0, frame=lines, mathescape, fontfamily=helvetica]{%s}
%s
\end{minted}
\end{listing}
]]

ListItemTemplate = [[
    \item %s
]]

EnumerateTemplate = [[
\begin{enumerate}
%s
\end{enumerate}
]]

ItemizeTemplate = [[
\begin{itemize}
%s
\end{itemize}
]]
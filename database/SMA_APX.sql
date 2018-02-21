create or replace package sma_apx
is

function geef_prijzen
  return t_apx_tab
  pipelined;

end;

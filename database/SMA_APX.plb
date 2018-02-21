create or replace package body sma_apx
is

function geef_prijzen
  return t_apx_tab
  pipelined
is
  cursor c_i
  is  
    select to_date('19700101', 'YYYYMMDD') + ( 1 / 24 / 60 / 60 / 1000) * to_number(jt.datum) + 1/24 as datum
    ,      lower(jt.tlabel) as label
    ,      jt.waarde
    ,      nullif(jt.unit,'none') as unit
    from   apex_collections col
    ,      json_table
              ( col.clob001
              ,  '$.quote[*]'  
              ERROR ON ERROR 
              COLUMNS 
                ( datum number path '$.date_applied'  
                , markt varchar2(255) path '$.market'
                , NESTED PATH '$.values[*]'
                  COLUMNS
                  ( tLabel varchar2(20) path '$.tLabel' 
                  , waarde varchar2(20) path '$.value' 
                  , unit   varchar2(20) path '$.unit' 
                  ) 
                )
           ) jt
    where  col.collection_name = 'P8_DOREST_RESULTS'
  ;
  l_apx_rij t_apx_rij := t_apx_rij(null,null,null,null,null);
  -- datum, <order, hour, net volume, price
begin
  for r_i in c_i
  loop
	if r_i.label = 'hour'
	then  
	  l_apx_rij.datum := r_i.datum + to_number(r_i.waarde)/24;
	elsif r_i.label = 'net volume'
	then  
	  l_apx_rij.net_volume  := to_number(r_i.waarde);
	  l_apx_rij.volume_unit := r_i.unit;
	elsif r_i.label = 'price'
	then
	  l_apx_rij.price      := to_number(r_i.waarde);
	  l_apx_rij.price_unit := r_i.unit;
      pipe row(l_apx_rij);
	  l_apx_rij := t_apx_rij(null,null,null,null,null);
	end if;
  end loop;
  return;
end;

end;

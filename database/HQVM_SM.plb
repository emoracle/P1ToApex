create or replace package body hqvm_sm
is

cursor gc_json
  ( cp_clob in clob
  )
is
  select version
  ,      elektijd
  ,      e1, e2, et1, et2, actueelvermogen, actueelterugleververmogen, gastijd, gas
  from  json_table(cp_clob,'$'
  columns (
      version  varchar2(30) path '$.version'
    , elektijd varchar2(33) path '$.elektijd'
    , e1       varchar2(30) path '$.e1'
    , e2       varchar2(30) path '$.e2'
    , et1      varchar2(30) path '$.et1'
    , et2      varchar2(30) path '$.et2'
    , actueelVermogen varchar2(30) path '$.actueelVermogen'
    , actueelTerugleverVermogen varchar2(30) path '$.actueelTerugleverVermogen'
    , gastijd  varchar2(33) path '$.gastijd'
    , gas      varchar2(30) path '$.gas'
  ))
;

gr_json gc_json%rowtype;

procedure corrigeer
is
   cursor c_i
     ( cp_tel varchar2
	 )
   is
    select datumtijd, stand
    ,      lead(stand) over ( order by datumtijd desc) vorige_stand
    ,      lead(datumtijd) over ( order by datumtijd desc) vorige_datum
    from   readings 
    where  telwerk = cp_tel
    order by datumtijd desc
  ;
  type t_telwerk_array IS VARRAY(5) OF VARCHAR2(4); 
  l_van date;
  l_aantal_uur   number;
  l_nieuwe_stand number;
  
  l_constante number;
  l_telwerken    t_telwerk_array := t_telwerk_array('E1','E2','ET1','ET2','GAS');
begin
  for l_telwerk in 1 .. l_telwerken.count
  loop
    l_constante := case when l_telwerken(l_telwerk) = 'GAS' then 24 else 96 end ;
    for r_i in c_i(l_telwerken(l_telwerk))
    loop
      if r_i.datumtijd - r_i.vorige_datum = 1/l_constante
	  then
	    null;
	  elsif r_i.datumtijd is not null and r_i.vorige_datum is not null
	  then
	    l_aantal_uur := l_constante*(r_i.datumtijd - r_i.vorige_datum) -1; 
	    l_van := r_i.datumtijd;
	    l_nieuwe_stand := r_i.stand;
	    for l_i in 1 .. (l_aantal_uur)
        loop
          l_van := l_van - 1/l_constante;
	      l_nieuwe_stand := round(l_nieuwe_stand - ((r_i.stand - r_i.vorige_stand)/l_aantal_uur),3);
          insert into readings (telwerk, datumtijd, stand) values (l_telwerken(l_telwerk), l_van, l_nieuwe_stand);
        end loop;
	  end if;
    end loop;
  end loop;  
end;

procedure bepaal_dayreadings
is 
  cursor c_rdg
  is
    select telwerk
    ,      trunc(datumtijd) as datumtijd
    ,      max(stand) as max_stand
    ,      min(stand) as min_stand
    ,      max(stand)-min(stand) as verbruik
    from   readings
    group  by telwerk
    ,      trunc(datumtijd)
  ;
begin
  corrigeer;
  --
  for r_rdg in c_rdg
  loop
    begin
      insert into day_readings
        ( telwerk, datumtijd, verbruik, min_stand, max_stand)
      values
        ( r_rdg.telwerk, r_rdg.datumtijd, r_rdg.verbruik, r_rdg.min_stand, r_rdg.max_stand);
    exception
      when dup_val_on_index
      then
        update day_readings
        set    verbruik = r_rdg.verbruik
        ,      min_stand = r_rdg.min_stand
        ,      max_stand = r_rdg.max_stand
        where  telwerk = r_rdg.telwerk
        and    datumtijd = r_rdg.datumtijd;
    end;
  end loop;
  /* Verwijder alles wat ouder is dan 3 dagen*/
  delete from readings where datumtijd < (trunc(sysdate)-3);
end ;

function clobfromblob
  ( p_blob blob
  ) return clob 
is
  l_clob         clob;
  l_dest_offsset integer := 1;
  l_src_offsset  integer := 1;
  l_lang_context integer := dbms_lob.default_lang_ctx;
  l_warning      integer;
begin
  if p_blob is null 
  then
    return null;
  end if;
  --
  dbms_lob.createTemporary(lob_loc => l_clob, cache   => false);
  dbms_lob.converttoclob
    ( dest_lob     => l_clob
    , src_blob     => p_blob
    , amount       => dbms_lob.lobmaxsize
    , dest_offset  => l_dest_offsset
    , src_offset   => l_src_offsset
    , blob_csid    => dbms_lob.default_csid
    , lang_context => l_lang_context
    , warning      => l_warning
    );
  return l_clob;
end;

function naarDatum
  ( p_string in varchar
  ) return date
is
  l_return date;
begin
  if p_string is not null
  then
    l_return := to_date(substr(p_string,1,length(p_string)-1),'RRMMDDhh24miss');
    /* De W aan het einde zal te maken hebben met zomer/wintertijd */
  end if;
  return l_return;
end ;

procedure ins
  (pr_new readings%rowtype
  )
is
begin
  if pr_new.datumtijd is not null
  then
    insert into readings values pr_new;
  end if;
exception
  when dup_val_on_index
  then
    null;
end;

procedure set_readings
is
  r_new readings%rowtype;
begin
  r_new.datumtijd := naarDatum(replace(gr_json.elektijd,'\u0000',null));
  r_new.telwerk   := 'E1';
  r_new.stand     := replace(gr_json.e1,'\u0000',null);
  ins(r_new);
  r_new.telwerk   := 'E2';
  r_new.stand     := replace(gr_json.e2,'\u0000',null);
  ins(r_new);
  r_new.telwerk   := 'ET1';
  r_new.stand     := replace(gr_json.et1,'\u0000',null);
  ins(r_new);
  r_new.telwerk   := 'ET2';
  r_new.stand     := replace(gr_json.et2,'\u0000',null);
  ins(r_new);
  r_new.telwerk   := 'ACV';
  r_new.stand     := replace(gr_json.actueelVermogen,'\u0000',null);
  --ins(r_new);
  r_new.telwerk   := 'ACTLV';
  r_new.stand     := replace(gr_json.actueelTerugleverVermogen,'\u0000',null);
  --ins(r_new);
  r_new.datumtijd := naarDatum(replace(gr_json.gastijd,'\u0000',null));
  r_new.telwerk   := 'GAS';
  r_new.stand     := replace(gr_json.gas,'\u0000',null);
  ins(r_new);
end;

procedure handle_readings
  ( p_json in blob
  )
is
  l_json clob;
begin
  /* Poor mans security :-) */
  if owa_util.get_cgi_env('X-FORWARDED-FOR') = '83.82.31.224'
  then
    --insert into requests values (p_json); commit;
    l_json := clobfromblob(p_json);
    if l_json is not null
    then
      open gc_json(l_json);
      fetch gc_json into gr_json;
      close gc_json;
      --
      set_readings;
    end if;
  else
    insert into logging values ('IP-adress is niet correct');
  end if;
  commit;  
  htp.p('gelukt');
exception
  when others
  then    
    htp.p(sqlerrm);
end;

end;

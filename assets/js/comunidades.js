
fetch('data/comunidades.json').then(r=>r.json()).then(d=>{
document.getElementById('lista').innerHTML=d.map(c=>`<p>${c.nome} - ${c.lider}</p>`).join('')
})

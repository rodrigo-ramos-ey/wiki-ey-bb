
fetch('data/comunidades.json')
  .then(r => r.json())
  .then(d => {
    document.getElementById('lista').innerHTML =
      d.map(c => `<p><strong>${c.nome}</strong> - Líder: ${c.lider}</p>`).join('');
  });

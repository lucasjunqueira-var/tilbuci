async function loadData() {
    try {
        const configRes = await fetch('/api/config');
        const config = await configRes.json();
        
        document.getElementById('wsInput').value = config.ws || '';
        document.getElementById('wsKeyInput').value = config.wsKey || '';
        document.getElementById('accesskeyInput').value = config.accesskey || 'AAAAA';
        document.getElementById('identifierInput').value = config.identifier || '';
        document.getElementById('autoStartInput').checked = !!config.autoStart;
        if (config.serialBaud) document.getElementById('serialBaudSelect').value = config.serialBaud;
        document.getElementById('hideCursorInput').checked = !!config.hideCursor;
        
        const serverStatus = document.getElementById('serverStatus');
        if (config.ws && config.wsKey && config.wsKey.length >= 5) {
            serverStatus.textContent = config.lastError !== null && config.lastError !== undefined
                ? 'Last communication error: ' + config.lastError
                : 'Last communication error: none';
        } else {
            serverStatus.textContent = 'No server communication: offline mode.';
        }
        
        const moviesRes = await fetch('/api/movies');
        const movies = await moviesRes.json();
        
        const movieSelect = document.getElementById('movieSelect');
        const deleteSelect = document.getElementById('deleteSelect');
        
        movieSelect.innerHTML = '<option value="">-- No movie selected --</option>';
        deleteSelect.innerHTML = '<option value="">-- Select a movie --</option>';
        
        movies.forEach(m => {
            let opt1 = document.createElement('option');
            opt1.value = m;
            opt1.textContent = m;
            if (config.movie === m) opt1.selected = true;
            movieSelect.appendChild(opt1);
            
            let opt2 = document.createElement('option');
            opt2.value = m;
            opt2.textContent = m;
            deleteSelect.appendChild(opt2);
        });
        
        setupCustomSelect('movieSelect', 'movieSelectWrapper');
        setupCustomSelect('deleteSelect', 'deleteSelectWrapper');
        
        try {
            const serialRes = await fetch('/api/serialports');
            const serialPorts = await serialRes.json();
            const serialPortSelect = document.getElementById('serialPortSelect');
            serialPortSelect.innerHTML = '<option value="">-- No port selected --</option>';
            serialPorts.forEach(p => {
                let opt = document.createElement('option');
                opt.value = p;
                opt.textContent = p;
                if (config.serialPort === p) opt.selected = true;
                serialPortSelect.appendChild(opt);
            });
        } catch (e) {}

        setupCustomSelect('serialPortSelect', 'serialPortSelectWrapper');
        setupCustomSelect('serialBaudSelect', 'serialBaudSelectWrapper');
    } catch (e) {
        console.error('Error loading data', e);
    }
}

function setupCustomSelect(selectId, wrapperId) {
    const wrapper = document.getElementById(wrapperId);
    const selElmnt = document.getElementById(selectId);
    
    // Remove existing custom select if re-running
    const existingSelected = wrapper.querySelector('.select-selected');
    if (existingSelected) existingSelected.remove();
    const existingItems = wrapper.querySelector('.select-items');
    if (existingItems) existingItems.remove();
    
    const a = document.createElement("DIV");
    a.setAttribute("class", "select-selected");
    a.innerHTML = selElmnt.options[selElmnt.selectedIndex].innerHTML;
    wrapper.appendChild(a);
    
    const b = document.createElement("DIV");
    b.setAttribute("class", "select-items select-hide");
    for (let i = 0; i < selElmnt.length; i++) {
        const c = document.createElement("DIV");
        c.innerHTML = selElmnt.options[i].innerHTML;
        if (i === selElmnt.selectedIndex) c.setAttribute("class", "same-as-selected");
        
        c.addEventListener("click", function(e) {
            const s = this.parentNode.parentNode.getElementsByTagName("select")[0];
            const h = this.parentNode.previousSibling;
            for (let j = 0; j < s.length; j++) {
                if (s.options[j].innerHTML == this.innerHTML) {
                    s.selectedIndex = j;
                    h.innerHTML = this.innerHTML;
                    const y = this.parentNode.getElementsByClassName("same-as-selected");
                    for (let k = 0; k < y.length; k++) {
                        y[k].removeAttribute("class");
                    }
                    this.setAttribute("class", "same-as-selected");
                    break;
                }
            }
            h.click();
        });
        b.appendChild(c);
    }
    wrapper.appendChild(b);
    
    a.addEventListener("click", function(e) {
        e.stopPropagation();
        closeAllSelect(this);
        this.nextSibling.classList.toggle("select-hide");
        this.classList.toggle("select-arrow-active");
    });
}

function closeAllSelect(elmnt) {
    const x = document.getElementsByClassName("select-items");
    const y = document.getElementsByClassName("select-selected");
    const arrNo = [];
    for (let i = 0; i < y.length; i++) {
        if (elmnt == y[i]) {
            arrNo.push(i)
        } else {
            y[i].classList.remove("select-arrow-active");
        }
    }
    for (let i = 0; i < x.length; i++) {
        if (arrNo.indexOf(i)) {
            x[i].classList.add("select-hide");
        }
    }
}

document.addEventListener("click", closeAllSelect);

async function saveSettings() {
    const movie = document.getElementById('movieSelect').value;
    const ws = document.getElementById('wsInput').value;
    const wsKey = document.getElementById('wsKeyInput').value;
    const accesskey = document.getElementById('accesskeyInput').value.toUpperCase();
    const identifier = document.getElementById('identifierInput').value;
    const autoStart = document.getElementById('autoStartInput').checked;
    const hideCursor = document.getElementById('hideCursorInput').checked;
    const serialPort = document.getElementById('serialPortSelect').value;
    const serialBaud = document.getElementById('serialBaudSelect').value;
    
    if (accesskey.length !== 5 || !/^[A-D]{5}$/.test(accesskey)) {
        return; // silently fail since we can't show alert easily, or maybe update UI. Let's just update UI or return.
    }

    try {
        await fetch('/api/config', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ movie, ws, wsKey, accesskey, identifier, autoStart, hideCursor, serialPort, serialBaud })
        });
        
        setTimeout(loadData, 500); // Reload to get updated server status
    } catch (e) {
        console.error('Error saving settings', e);
    }
}

async function uploadMovie() {
    const fileInput = document.getElementById('zipFile');
    if (!fileInput.files.length) {
        return;
    }
    
    const formData = new FormData();
    formData.append('file', fileInput.files[0]);
    
    document.getElementById('uploadStatus').textContent = 'Uploading and extracting...';
    
    try {
        const res = await fetch('/api/upload', {
            method: 'POST',
            body: formData
        });
        const data = await res.json();
        if (data.success) {
            document.getElementById('uploadStatus').textContent = 'Upload successful!';
            fileInput.value = '';
            document.getElementById('fileNameDisplay').textContent = 'No file chosen';
            loadData();
        } else {
            document.getElementById('uploadStatus').textContent = 'Error: ' + data.error;
        }
    } catch (e) {
        document.getElementById('uploadStatus').textContent = 'Upload failed.';
    }
}

async function deleteMovie() {
    const movie = document.getElementById('deleteSelect').value;
    if (!movie) return;
    
    try {
        await fetch('/api/delete', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ movie })
        });
        loadData();
    } catch (e) {
        console.error('Error deleting movie', e);
    }
}

function goToApp() {
    window.location.href = '/index.html';
}

window.onload = loadData;

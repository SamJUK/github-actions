// Sample JS Script that can be ran in the browser console to extract software requirements from Magento DevDocs
// The script output, will need some minor adjustments to be used in the action.
// https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements
let versions = {};
document.querySelectorAll('[role="tabpanel"][aria-labelledby="tab-0-1"] tbody tr').forEach(table => {
    const software = table.querySelector('[data-title="Software dependencies"]').innerText.trim().toLowerCase().replace(/[ \(\))]/g, '_');

    if (software.toLowerCase().startsWith('aws')) {
        return;
    }

    table.querySelectorAll('[data-title]').forEach(row => {
        if (row.getAttribute('data-title') === 'Software dependencies') { 
            return;
        }

        const magento_version = row.getAttribute('data-title');
        let software_version = row.innerText.trim();

        if (software_version.indexOf(',') !== -1) {
            software_version = software_version.split(',')[0].trim();
        }

        if (software_version.indexOf(' or latest available') !== -1) {
            software_version = software_version.replace(' or latest available', '').trim();
        }


        if (!versions[magento_version]) {
            versions[magento_version] = {};
        }

        versions[magento_version][software] = software_version;
    });
});

console.log(versions);
copy(JSON.stringify(versions, null, 4));
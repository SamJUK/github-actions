<?php
// Every tracked XML file is well-formed. PHP's own parser, because ubuntu-24.04 runners have no xmllint.
libxml_use_internal_errors(true);
exec("git ls-files -z -- '*.xml' '*.xml.dist' '*.xsd'", $output, $rc);
if ($rc !== 0) {
    exit(1);
}
$files = array_filter(explode("\0", implode("\n", $output)));

$malformed = 0;
foreach ($files as $file) {
    libxml_clear_errors();
    if ((new DOMDocument())->load($file, LIBXML_NONET) === false) {
        foreach (libxml_get_errors() as $error) {
            printf("::error file=%s,line=%d::%s\n", $file, $error->line, trim($error->message));
        }
        $malformed++;
    }
}
printf("%d files, %d malformed\n", count($files), $malformed);
exit($malformed ? 1 : 0);

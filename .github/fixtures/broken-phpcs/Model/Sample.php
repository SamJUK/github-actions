<?php

declare(strict_types=1);

namespace SamJUK\BrokenPhpcs\Model;

class Sample
{
    public function hash(string $value): string
    {
        return md5($value);
    }
}

<?php

declare(strict_types=1);

namespace SamJUK\DemoPhpstanMagento\Model;

use Magento\Framework\DataObject;
use Magento\Framework\DataObjectFactory;

// DataObjectFactory only exists once bitexpert/phpstan-magento (or Magento) generates it.
class UsesGeneratedFactory
{
    public function __construct(private DataObjectFactory $dataObjectFactory)
    {
    }

    public function create(): DataObject
    {
        return $this->dataObjectFactory->create();
    }
}

<?php

require 'vendor/autoload.php';

use App\Result;
use App\ResultItem;

use App\Engine\Wikipedia\WikipediaEngine;
use App\Engine\Wikipedia\WikipediaParser;

use Symfony\Component\Console\Application;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\HttpClient\HttpClient;
use Symfony\Component\Console\Formatter\OutputFormatterStyle;
use Symfony\Component\Console\Helper\Table;

class SearchCommand extends Command
{
    protected function configure()
    {
        $this
            ->setName('find')
            ->setDescription('Scraps wikipedia for term')
            ->addArgument('term', InputArgument::REQUIRED,'Term to search for')
            ->addArgument('results', InputArgument::OPTIONAL,'Term to search for');
    }
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $wikipedia = new WikipediaEngine(new WikipediaParser(), HttpClient::create());

       $response = $wikipedia->search($input->getArgument('term'));
       $resultCount = $input->getArgument('results');
       
       $output->writeln($response->count()." results found for the term: ".$input->getArgument('term'));

       $results = 1; 

       foreach($response as $item)
       {
           if($resultCount)
           {
            if($results <= $resultCount){
                $rows[] = [
                    $item->getTitle(), 
                    $item->getPreview(),
                ];
                $results++;
                }
            }
            else{
                $rows[] = [
                    $item->getTitle(), 
                    $item->getPreview(),
                ];
            }
       }
       $table = new Table($output);
       $table
           ->setHeaders(['Page title','Page preview'])
           ->setRows($rows);
       $table->render();

        return 0;
    }
}
$app = new Application();
$app->add(new SearchCommand());
$app->run();
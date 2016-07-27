Rails.application.routes.draw do
	root 'main#home'
	get 'search' => 'main#search'
end 

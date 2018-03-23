Rails.application.routes.draw do
	root 'rooms#main'
	get '/find' => 'rooms#index'
end 

Rails.application.routes.draw do
	root 'rooms#home'
	get 'find' => 'rooms#index'
end 

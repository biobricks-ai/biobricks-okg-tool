package Bio_Bricks::KG::App::YAML::Editor;
# ABSTRACT: Terminal editor for OKG ML

use Mu;
use CLI::Osprey;

use Bio_Bricks::Common::Setup;
use curry;

use Curses::UI;
use Curses::UI::Grid;


with qw(
	Bio_Bricks::KG::App::Role::BaseDirOption
);

lazy model => method() {
	my $model = Bio_Bricks::KG::Mapping::OKGML::Model->new(
		base_dir => $self->base_dir
	);
};

lazy cui => sub {
	my $cui = Curses::UI->new(
		-color_support => 1,
		#-debug => 1,
	);
};

method layout() {
	my $cui = $self->cui;

	my @menu = (
		{ -label => 'File', 
			-submenu => [
				{ -label => 'Exit      ^Q', -value => $self->curry::exit_dialog  }
			]
		},
	);
	 
	my $menu = $cui->add(
		'menu','Menubar', 
		-menu => \@menu,
		-fg  => "blue",
	);

	my $win1 = $cui->add(
		'win1', 'Window',
		-border => 1,
		-y    => 1,
		-bfg  => 'red',
	);

	my $grid = $win1->add('grid'
		,'Grid'
		#,-height=>20
		#,-bg => "blue"
		#,-fg => "white"
		,-editable=>0
		,-columns=>4
	);

	$grid->set_label( 'cell1' => 'Dataset' );
	$grid->set_label( 'cell2' => 'Input' );
	$grid->set_label( 'cell3' => 'Column' );
	$grid->set_label( 'cell4' => 'Class' );
	$grid->layout_content;

	$grid->add_row( undef );
	$grid->add_row( undef );
	$grid->add_row( undef );
	$grid->add_row( undef );

	$cui->set_binding(sub {$menu->focus()}, "\cX");
	$cui->set_binding( $self->curry::exit_dialog , "\cQ");

	$grid->focus();
}


method exit_dialog() {
	my $return = $self->cui->dialog(
		-message   => "Do you really want to quit?",
		-title     => "Are you sure???", 
		-buttons   => ['yes', 'no'],
	);

	exit(0) if $return;
}

method run() {
	$self->layout;
	$self->cui->mainloop();
}

1;

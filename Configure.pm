=head2 NAME

  OSBB Configure

=cut

use warnings;
use strict;

our (
  $db,
  $admin,
  %conf,
  %lang,
  $html,
);


my $Osbb = Osbb->new($db, $admin, \%conf);


#**********************************************************
=head2 osbb_config($attr)

=cut
#**********************************************************
sub osbb_config {


  return 1;
}

#**********************************************************
=head2 osbb_spending_types() -

  Arguments:
    $attr -
  Returns:

  Examples:

=cut
#**********************************************************
sub osbb_spending_types {
  my ($attr) = @_;

  $Osbb->{ACTION}     = 'add';
  $Osbb->{LNG_ACTION} = $lang{ADD};

   if ( $FORM{add} ){
    $Osbb->spending_types_add( { %FORM } );
    if ( !$Osbb->{errno} ){
      $html->message( 'info', $lang{SPENDING_TYPES}, "$lang{ADDED}" );
    }
  }
  elsif ( $FORM{change} ){
    $Osbb->spending_types_change( \%FORM );
    if ( !_error_show( $Osbb ) ){
      $html->message( 'info', $lang{SPENDING_TYPES}, "$lang{CHANGED}" );
    }
  }
  elsif ( $FORM{chg} ){
    $Osbb->spending_types_info( "$FORM{chg}" );

    if ( !$Osbb->{errno} ){
      $Osbb->{ACTION} = 'change';
      $Osbb->{LNG_ACTION} = "$lang{CHANGE}";
      $FORM{add_form} = 1;
      $html->message( 'info', $lang{SPENDING_TYPES}, "$lang{CHANGING}" );
    }
  }
  elsif ( $FORM{del} && $FORM{COMMENTS} ){
    $Osbb->spending_types_del( "$FORM{del}" );
    if ( !$Osbb->{errno} ){
      $html->message( 'info', $lang{SPENDING_TYPES}, "$lang{DELETED}" );
    }
  }

  if ( $FORM{add_form} ){
    $html->tpl_show( _include( 'osbb_spending_types', 'Osbb' ), $Osbb );
  }

  result_former({
    INPUT_DATA      => $Osbb,
    FUNCTION        => 'spending_type_list',
    BASE_FIELDS     => 2,
    FUNCTION_FIELDS => 'change,del',
    SKIP_USER_TITLE => 1,
    EXT_TITLES      => {
      name         => $lang{NAME},
      comments     => $lang{COMMENTS},
    },
    TABLE           => {
      width   => '100%',
      caption => "$lang{SPENDING} $lang{TYPE}",
      qs      => $pages_qs,
      ID      => 'SPENDING_TYPES',
      EXPORT  => 1,
      MENU    => "$lang{ADD}:index=$index&add_form=1&$pages_qs:add",
    },
    MAKE_ROWS       => 1,
    SEARCH_FORMER   => 1,
    TOTAL           => 1
  });

  return 1;
}

#**********************************************************
=head2 osbb_user_main()

=cut
#**********************************************************
sub osbb_user_main {
  my %TEMPLATE_ARGS = ();
  my $show_add_form = $FORM{add_form} || 0;
  
  if ($FORM{add}) {
    $Osbb->user_add({%FORM});
    $show_add_form = show_result($Osbb, $lang{ADDED});
  }
  elsif ($FORM{change}) {
    $Osbb->user_change({%FORM});
    show_result($Osbb, $lang{CHANGED});
    $show_add_form = 1;
  }
  elsif ($FORM{chg}) {
    my $tp_info = $Osbb->user_info($FORM{chg});
    if (!_error_show($Osbb)) {
      %TEMPLATE_ARGS = %{$tp_info};
      $show_add_form = 1;
    }
  }
  elsif ($FORM{del} && $FORM{COMMENTS}) {
    $Osbb->user_del({ ID => $FORM{del}, COMMENTS => $FORM{COMMENTS} });
    show_result($Osbb, $lang{DELETED});
  }
  
  if ($show_add_form) {
    
    
    $html->tpl_show(
      _include('osbb_user', 'Osbb'),
      {
        %TEMPLATE_ARGS,
        %FORM,
        SUBMIT_BTN_ACTION => ($FORM{chg}) ? 'change' : 'add',
        SUBMIT_BTN_NAME   => ($FORM{chg}) ? $lang{CHANGE} : $lang{ADD},
      }
    );
  }
}

1;
#if defined _fcs_included
	#endinput
#endif

#define _fcs_included



/*
 * Returns a players credits
 * 
 * @param		client - The player index to get points of
 * 
 * @return		The credits client
 * 
 */

native fcs_get_user_credits(client);

/*
 * Sets <credits> to client
 * 
 * @param		client - The player index to set points to
 * @param		credits - The amount of credits to set to client
 * 
 * @return		The credits of client
 * 
 */

native fcs_set_user_credits(client, credits);

/*
 * Adds <credits> points to client
 * 
 * @param		client - The player index to add points to
 * @param		credits - The amount of credits to set to client
 * 
 * @return		The credits of client
 * 
 */

stock fcs_add_user_credits(client, credits)
{
	return fcs_set_user_credits(client, fcs_get_user_credits(client) + credits);
}

/*
 * Subtracts <credits>  from client
 * 
 * @param		client - The player index to subtract points from
 * @param		credits - The amount of credits to set to client
 * 
 * @return		The credits of client
 * 
 */

stock fcs_sub_user_credits(client, credits)
{
	return fcs_set_user_credits(client, fcs_get_user_credits(client) - credits);
}